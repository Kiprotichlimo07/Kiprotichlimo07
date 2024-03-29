table 687 "Payment Practice Header"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Starting Date"; Date)
        {

        }
        field(3; "Ending Date"; Date)
        {

        }
        field(4; "Aggregation Type"; Enum "Paym. Prac. Aggregation Type")
        {
            trigger OnValidate()
            begin
                ValidateFieldChange(Rec."Aggregation Type");
                Rec.CalcFields("Lines Exist");
                if not Rec."Lines Exist" then
                    exit;

                if ConfirmManagement.GetResponseOrDefault(StrSubstNo(ClearHeaderQst, FieldCaption("Aggregation Type")), true) then
                    ClearHeader()
                else
                    "Aggregation Type" := xRec."Aggregation Type";
            end;
        }
        field(5; "Header Type"; Enum "Paym. Prac. Header Type")
        {
            trigger OnValidate()
            begin
                ValidateFieldChange(Rec."Aggregation Type");
                Rec.CalcFields("Lines Exist");
                if not Rec."Lines Exist" then
                    exit;

                if ConfirmManagement.GetResponseOrDefault(StrSubstNo(ClearHeaderQst, FieldCaption("Header Type")), true) then
                    ClearHeader()
                else
                    "Header Type" := xRec."Header Type";
            end;
        }
        field(6; "Average Agreed Payment Period"; Integer)
        {
            trigger OnValidate()
            begin
                Rec."Modified Manually" := true;
            end;
        }
        field(7; "Average Actual Payment Period"; Integer)
        {
            trigger OnValidate()
            begin
                Rec."Modified Manually" := true;
            end;
        }
        field(8; "Pct Paid on Time"; Decimal)
        {
            trigger OnValidate()
            begin
                Rec."Modified Manually" := true;
            end;
        }
        field(9; "Generated On"; DateTime)
        {

        }
        field(10; "Generated By"; Code[20])
        {

        }
        field(11; "Lines Exist"; Boolean)
        {
            CalcFormula = exist("Payment Practice Line" where("Header No." = field("No.")));
            FieldClass = FlowField;
        }
        field(12; "Modified Manually"; Boolean)
        {

        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        UpdateNo();
    end;

    trigger OnDelete()
    begin
        DeleteLinkedRecords();
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        ClearHeaderQst: Label 'Changing %1 will delete existing lines. Do you want to continue?', Comment = '%1 = Field name';

    procedure UpdateNo(): Integer
    var
        SequenceNoMgt: Codeunit "Sequence No. Mgt.";
    begin
        if Rec."No." = 0 then
            Rec.Validate("No.", SequenceNoMgt.GetNextSeqNo(Database::"Payment Practice Header"));
    end;

    local procedure DeleteLinkedRecords()
    var
        PaymentPracticeLine: Record "Payment Practice Line";
        PaymentPracticeData: Record "Payment Practice Data";
    begin
        PaymentPracticeLine.SetRange("Header No.", "No.");
        PaymentPracticeLine.DeleteAll();
        PaymentPracticeData.SetRange("Header No.", "No.");
        PaymentPracticeData.DeleteAll();
        Rec.CalcFields("Lines Exist");
    end;

    procedure ClearHeader()
    begin
        "Generated On" := 0DT;
        "Generated By" := '';
        DeleteLinkedRecords();
    end;

    local procedure ValidateFieldChange(PaymentPracticeLinesAggregator: Interface PaymentPracticeLinesAggregator)
    begin
        PaymentPracticeLinesAggregator.ValidateHeader(Rec);
    end;
}