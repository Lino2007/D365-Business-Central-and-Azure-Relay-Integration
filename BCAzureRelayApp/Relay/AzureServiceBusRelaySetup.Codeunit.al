// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 50140 AzureServiceBusRelaySetup
{
    // Warning reports: 'Table 'Service Connection' is marked for removal. Reason: Table will be marked as TableType=Temporary. Make sure you are not using this table to store records.. Tag: 21.0.'
    // I have decided to leave this code here anyway and only suppress the warning. Keep in mind that this code may be subject to change in the future.
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection");
#pragma warning restore AL0432
    var
        AzureServiceBusRelaySetup: Record AzureServiceBusRelaySetup;
        RecRef: RecordRef;
    begin
        if not AzureServiceBusRelaySetup.Get() then begin
            if not AzureServiceBusRelaySetup.WritePermission() then
                exit;
            AzureServiceBusRelaySetup.Init();
            AzureServiceBusRelaySetup.Insert();
        end;

        RecRef.GetTable(AzureServiceBusRelaySetup);
        if AzureServiceBusRelaySetup.IsEnabled then
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        else
            ServiceConnection.Status := ServiceConnection.Status::Disabled;

        ServiceConnection.InsertServiceConnection(
            ServiceConnection, RecRef.RecordId(), AzureServiceBusRelaySetup.TableCaption(),
            AzureServiceBusRelaySetup.GetServiceUri(),
            PAGE::AzureServiceBusRelaySetup);

    end;

}