function fish_user_key_bindings
    # Remove the default binding and add the Emacs style binding to edit command buffer.
    bind --erase --preset alt-e
    bind --erase --preset alt-v
    bind ctrl-x,ctrl-e edit_command_buffer
end
