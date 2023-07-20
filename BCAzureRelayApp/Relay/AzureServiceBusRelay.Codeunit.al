// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 50139 AzureServiceBusRelay
{
    //
    // ServiceBus Relay REST functionality
    //

    var
        SharedAccessTokenGenerator: codeunit SharedAccessTokenGenerator;
        BaseRelayUri: Text;
        SharedKeyName: Text;
        [NonDebuggable]
        SharedKey: Text;
        LastReasonPhrase: Text;
        RelayNotEnabledErr: label 'AzureServiceBusRelay is not set-up. Please go to Service Connections to set-up';
        RequestErr: Label 'HttpError Code:%1, Reason:%2', Locked = true;
        BaseRelayUriLbl: Label 'https://%1.servicebus.windows.net/%2%3', Locked = true;

    //
    // Initialize the ServiceBus Relay from the persisted setup.
    // 
    procedure Initialize(AzureRelaySetupCode: Code[20]);
    begin
        Initialize(AzureRelaySetupCode, '');
    end;

    //
    // Initialize the ServiceBus Relay from the persisted setup.
    // 
    procedure Initialize(AzureRelayCode: Code[20]; SubBaseUri: Text);
    var
        AzureServiceBusRelaySetup: Record AzureServiceBusRelaySetup;
    begin
        if not AzureServiceBusRelaySetup.Get(AzureRelayCode) then
            Error(RelayNotEnabledErr);

        if not AzureServiceBusRelaySetup.IsEnabled then
            Error(RelayNotEnabledErr);

        BaseRelayUri := StrSubstNo(BaseRelayUriLbl,
            AzureServiceBusRelaySetup.AzureRelayNamespace,
            AzureServiceBusRelaySetup.HybridConnectionName,
            SubBaseUri);
        SharedKeyName := AzureServiceBusRelaySetup.KeyName;
        SharedKey := AzureServiceBusRelaySetup.GetSharedAccessKey();
    end;

    [TryFunction]
    procedure Get(AzureRelaySetupCode: Code[20]; SubRelayUri: Text; var content: Text);
    var
        response: HttpResponseMessage;
    begin
        Initialize(AzureRelaySetupCode);
        Get(SubRelayUri, response);
        response.Content().ReadAs(content);
    end;

    [TryFunction]
    procedure Get(AzureRelaySetupCode: Code[20]; SubRelayUri: Text; var content: InStream);
    var
        response: HttpResponseMessage;
    begin
        Initialize(AzureRelaySetupCode);
        Get(SubRelayUri, response);
        response.Content().ReadAs(content);
    end;

    local procedure Get(SubRelayUri: Text; var response: HttpResponseMessage)
    var
        client: HttpClient;
        req: HttpRequestMessage;
    begin
        InitializeRequest('GET', BaseRelayUri + SubRelayUri, req);
        client.Send(req, response);
        if not CheckResponse(response) then
            Error(RequestErr, response.HttpStatusCode(), response.ReasonPhrase());
    end;

    procedure Put(AzureRelaySetupCode: Code[20]; SubRelayUri: Text; input: Text; var result: Text);
    var
        request: HttpRequestMessage;
        response: HttpResponseMessage;
    begin
        Initialize(AzureRelaySetupCode);
        request.Content().WriteFrom(input);
        Put(SubRelayUri, request, response);
        response.Content().ReadAs(result);
    end;

    procedure Put(AzureRelaySetupCode: Code[20]; SubRelayUri: Text; Input: InStream; Length: Integer; ContentType: Text; var result: Text);
    var
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        headers: HttpHeaders;
    begin
        Initialize(AzureRelaySetupCode);

        request.Content().WriteFrom(Input);
        request.Content().GetHeaders(headers);
        headers.Add('Content-Length', Format(Length));
        headers.Add('Content-Type', ContentType);

        Put(SubRelayUri, request, response);
        response.Content().ReadAs(result);
    end;

    local procedure Put(SubRelayUri: Text; request: HttpRequestMessage; var response: HttpResponseMessage)
    var
        Client: HttpClient;
    begin
        InitializeRequest('PUT', BaseRelayUri + SubRelayUri, request);
        Client.Send(request, response);
        CheckResponse(response);
    end;

    local procedure InitializeRequest(Verb: Text; Uri: Text; var Request: HttpRequestMessage)
    var
        Headers: HttpHeaders;
    begin
        Request.GetHeaders(Headers);
        Headers.Add('ServiceBusAuthorization', SharedAccessTokenGenerator.GetSasToken(Uri, SharedKeyName, SharedKey));
        Request.Method := Verb;
        Request.SetRequestUri(Uri);
    end;

    local procedure CheckResponse(var response: HttpResponseMessage): Boolean
    begin
        if not response.IsSuccessStatusCode() then begin
            LastReasonPhrase := response.ReasonPhrase();
            exit(false);
        end;

        LastReasonPhrase := '';
        exit(true);
    end;

}