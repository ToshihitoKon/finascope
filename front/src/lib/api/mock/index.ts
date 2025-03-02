import type { RecordType } from "types";

export const fetchRecordTypesMock = async (): Promise<RecordType[]> => {
	return [
		{ value: "expense", label: "Expense" },
		{ value: "income", label: "Income" },
	];
};
