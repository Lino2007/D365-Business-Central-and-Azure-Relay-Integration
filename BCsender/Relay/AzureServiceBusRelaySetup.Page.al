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
                field(Id; Rec.ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id of Azure Relay setup entry';
                }
                field(AzureRelayNamespace; Rec.AzureRelayNamespace)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the namespace of the Azure Relay namespace';
                }
                field(HybridConnectionName; Rec.HybridConnectionName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Hybrid Connection ';
                }
                field(SharedAccessPolicyName; Rec.SharedAccessPolicyName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Shared Access Policy for authentication (Azure Relay namespace)';
                }
                field(SharedAccessPolicyPrimaryKey; SharedAccessPolicyPrimaryKey)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    Caption = 'Primary Key';
                    ToolTip = 'Specifies the primary key from Shared Access Policy of selected Relay namespace';

                    trigger OnValidate()
                    begin
                        if (SharedAccessPolicyPrimaryKey <> '') and (not EncryptionEnabled()) then
                            if Confirm(EncryptionIsNotActivatedQst) then
                                PAGE.RunModal(PAGE::"Data Encryption Management");
                        Rec.SetSharedAccessKey(SharedAccessPolicyPrimaryKey);
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
                Caption = 'Test connection';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Tests connection to listener API endpoint via Azure Relay Hybrid Connection.';
                Image = Default;

                trigger OnAction()
                var
                    AzureRelay: Codeunit AzureServiceBusRelay;
                    Result: Text;
                begin
                    AzureRelay.Get(Rec.ID, '/Hello', Result);
                    Message(Result);
                end;
            }
        }
    }

    var
        SharedAccessPolicyPrimaryKey: Text;
        EncryptionIsNotActivatedQst: Label 'Data encryption is currently not enabled. We recommend that you encrypt data. \Do you want to open the Data Encryption Management window?';

    trigger OnAfterGetRecord()
    begin
        if Rec.HasSharedAccessKey() then
            SharedAccessPolicyPrimaryKey := '*';
    end;
}