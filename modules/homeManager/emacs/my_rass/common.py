from typing import Any, cast

from rassumfrassum.frassum import LspLogic, Server
from rassumfrassum.json import JSON
from rassumfrassum.util import dmerge


def codebook() -> list[str]:
    return ["codebook-lsp", "serve"]


def harper() -> list[str]:
    return ["harper-ls", "--stdio"]


def typos() -> list[str]:
    return ["typos-lsp"]


CONFIGURATION_HARPER_LS = {
    "harper-ls": {
        "linters": {
            "ExpandTimeShorthands": True,
            "UseTitleCase": False,
            "SentenceCapitalization": False,
            "ExpandControl": False,
            "ExpandPrevious": False,
            "MoreAdjective": False,
            "ExpandArgument": False,
            "SplitWords": False,
            "UnclosedQuotes": False,
            "ExpandStandardInputAndOutput": False,
            "Spaces": False,
            "SpellCheck": False,
            "OrthographicConsistency": False,
            "Dashes": False,
            "EllipsisLength": False,
            "ExpandMemoryShorthands": False,
            "DisjointPrefixes": False,
            "LongSentences": False,
            "CapitalizePersonalPronouns": False,
        }
    },
}


def make_logic_class_for_static_configuration(
    *,
    class_name: str,
    class_qualname: str,
    server_regexp_str: str,
    server_name: str,
    configuration: dict[str, Any],
):
    class StaticConfigurationLogicClass(LspLogic):
        def process_request(
            self, method: str, params: JSON, server: Server
        ) -> JSON | None:
            if method == "initialize":
                params = dmerge(
                    params,
                    {
                        "initializationOptions": {
                            "rass": {
                                server_regexp_str: configuration,
                            },
                        },
                    },
                )
            return super().process_request(method, params, server)

        async def on_client_notification(self, method: str, params: JSON) -> None:
            # As of rassumfrassum 0.3.4, it can handle configuration in initialize and workspace/configuration,
            # but not in workspace/didChangeConfiguration.
            # See https://github.com/joaotavora/rassumfrassum/issues/34
            #
            # In my observation, if inconsistent configuration is passed to harper-ls,
            # it will discard any valid previously seen configuration.
            # Therefore, it is important to return a stable configuration in all circumstances.
            #
            # Eglot is programmed to send this notification once connected.
            # See https://github.com/emacs-mirror/emacs/blob/emacs-30.2/lisp/progmodes/eglot.el#L1504
            if method == "workspace/didChangeConfiguration":
                params = dmerge(
                    params,
                    {
                        "settings": {
                            server_name: configuration,
                        },
                    },
                )
            await super().on_client_notification(method, params)

        async def on_client_response(
            self,
            method: str,
            request_params: JSON,
            response_payload: JSON,
            is_error: bool,
            server: Server,
        ) -> None:
            if method == "workspace/configuration" and not is_error:
                response_payload = cast(Any, response_payload)
                for i, item in enumerate(response_payload):
                    if item is None:
                        item = {}
                    item = dmerge(
                        item,
                        {
                            "rass": {
                                server_regexp_str: configuration,
                            },
                        },
                    )
                    response_payload[i] = item

            await super().on_client_response(
                method, request_params, response_payload, is_error, server
            )

    # rassumfrassum is programmed to import class,
    # even we are returning the actual class object in `logic_class` function.
    # In order to let rassumfrassum being able to load the class,
    # we have to make this dynamically generated class a real member of the module.
    # 3 steps are needed:
    # 1. Define a module item holding the class object.
    # 2. Set __name__ of the class object to match the name used in step 1.
    # 3. Set __qualname__ of the class object to match its intended full name.
    #
    # See https://github.com/joaotavora/rassumfrassum/blob/v0.3.4/src/rassumfrassum/main.py#L147
    # See https://github.com/joaotavora/rassumfrassum/blob/v0.3.4/src/rassumfrassum/rassum.py#L147
    StaticConfigurationLogicClass.__name__ = class_name
    StaticConfigurationLogicClass.__qualname__ = class_qualname
    return StaticConfigurationLogicClass


HarperLogicClass = make_logic_class_for_static_configuration(
    class_name="HarperLogicClass",
    class_qualname=f"{__name__}.HarperLogicClass",
    server_regexp_str="harper-ls",
    server_name="harper-ls",
    configuration=CONFIGURATION_HARPER_LS,
)
