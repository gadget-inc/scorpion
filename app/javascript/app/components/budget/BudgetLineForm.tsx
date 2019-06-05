import React from "react";
import { Draggable } from "react-beautiful-dnd";
import { TrashButton } from "../common";
import { Formant } from "flurishlib/formant";
import { Box } from "grommet";
import { Row } from "flurishlib";
import { BudgetFormLineValue } from "./BudgetForm";
import { FieldArrayRenderProps } from "formik";

export interface BudgetLineFormProps {
  lineFieldKey: string;
  line: BudgetFormLineValue;
  index: number;
  arrayHelpers: FieldArrayRenderProps;
}

export class BudgetLineForm extends React.Component<BudgetLineFormProps> {
  render() {
    return (
      <Draggable draggableId={`line-${this.props.line.key}`} index={this.props.index}>
        {provided => (
          <Row pad="small" gap="medium" wrap ref={provided.innerRef as any} {...provided.draggableProps} {...provided.dragHandleProps}>
            <Box width="medium">
              <Formant.Input name={`${this.props.lineFieldKey}.description`} placeholder="Line description" />
            </Box>
            <Box width="small">
              <Formant.Select
                name={`${this.props.lineFieldKey}.variable`}
                options={[{ value: true, label: "Variable" }, { value: false, label: "Fixed" }]}
              />
            </Box>
            <Box width="small">
              <Formant.Select
                name={`${this.props.lineFieldKey}.frequency`}
                options={[
                  { value: "daily", label: "Daily" },
                  { value: "weekly", label: "Weekly" },
                  { value: "monthly-first", label: "Monthly on the first business day" },
                  { value: "monthly-last", label: "Monthly on the last business day" },
                  { value: "quarterly-first", label: "Quarterly on the first business day" },
                  { value: "custom", label: "Custom" }
                ]}
              />
            </Box>
            <Box width="small">
              <Formant.NumberInput
                name={`${this.props.lineFieldKey}.amount`}
                prefix={"$"}
                fixedDecimalScale
                decimalScale={2}
                placeholder="Line amount"
              />
            </Box>
            <Box>
              <TrashButton onClick={() => this.props.arrayHelpers.remove(this.props.index)} />
            </Box>
          </Row>
        )}
      </Draggable>
    );
  }
}
