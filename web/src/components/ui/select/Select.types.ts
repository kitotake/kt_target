export type SelectOption = {
  value: string;
  label: string;
  disabled?: boolean;
};

export interface SelectProps {
  label?:       string;
  options:      SelectOption[];
  value?:       string;
  placeholder?: string;
  disabled?:    boolean;
  onChange?:    (value: string) => void;
  className?:   string;
}
