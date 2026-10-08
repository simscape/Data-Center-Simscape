classdef getPDURacksTL
    methods(Static)
        % Use the code browser on the left to add the callbacks.
        function getRatingButton(callbackContext)
            getRatingForPDU(gcb,"PDU");
        end
    end
end