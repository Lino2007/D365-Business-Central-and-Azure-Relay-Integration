// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 50140 AzureServiceBusRelaySetup
{
    Caption = 'Azure Service Bus Relay Setup';
    SourceTable = AzureServiceBusRelaySetup;
    UsageCategory = Administration;
    ApplicationArea = All;
    PageType = List;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(PrimaryKey; Rec.PrimaryKey)
                {
                    ApplicationArea = All;
                    ToolTip = 'Primary Key';
                }
                field(AzureRelayNamespace; Rec.AzureRelayNamespace)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the namespace of the Azure Relay';
                }
                field(HybridConnectionName; Rec.HybridConnectionName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Hybrid Connection ';
                }
                field(KeyName; Rec.KeyName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Shared Access Policy for authentication';
                }
                field(SharedAccessKey; SharedAccessKeyValue)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    Caption = 'Shared Access Key/Primary Key';
                    ToolTip = 'Specifies the primary key from Shared Access Policy of selected Relay';

                    trigger OnValidate()
                    begin
                        if (SharedAccessKeyValue <> '') and (not EncryptionEnabled()) then
                            if Confirm(EncryptionIsNotActivatedQst) then
                                PAGE.RunModal(PAGE::"Data Encryption Management");
                        Rec.SetSharedAccessKey(SharedAccessKeyValue);
                    end;
                }

                field(IsEnabled; Rec.IsEnabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the Azure Service Bus Relay integration is enabled';
                }
            }

        }

    }

    actions
    {
        area(Processing)
        {
            action(TestConnection)
            {
                Caption = 'Test connection to Azure Relay';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Test connection to Azure Relay.';
                Image = Default;

                trigger OnAction()
                var
                    AzureRelay: Codeunit AzureServiceBusRelay;
                    Result: Text;
                begin
                    AzureRelay.Get(Rec.PrimaryKey, '/Hello', Result);
                    Message(Result);
                end;
            }
        }
    }

    var
        SharedAccessKeyValue: Text;
        EncryptionIsNotActivatedQst: Label 'Data encryption is currently not enabled. We recommend that you encrypt data. \Do you want to open the Data Encryption Management window?';

    trigger OnAfterGetRecord()
    begin
        if Rec.HasSharedAccessKey() then
            SharedAccessKeyValue := '*';
    end;
}