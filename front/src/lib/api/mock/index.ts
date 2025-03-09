import type * as apitype from "../types";

export const fetchCategories = async (): Promise<apitype.CategoriesResponse> => {
    return {
        categories: [
            { id: "01JNB8PFPXAC808XH263PS7TW9", label: "DIALOGUE+" },
            { id: "01JNB8PNR9RT2HF21PVRFSW5NV", label: "その他" },
        ]
    };
};

export const fetchRecords = async (): Promise<apitype.RecordsResponse> => {
    return {
        records: [
            {
                id: "01JNBK19Q5E0CQC3A9D7QS56Z7",
                typeId: 1,
                stateId: 1,
                description: "全通",
                amount: 66800,
                categoryId: "01JNB8PFPXAC808XH263PS7TW9",
                date: "2025-02-20T00:00:00Z"
            },
            {
                id: "01JNBK19Q5S3PFBYG0C0E1CFKR",
                typeId: 1,
                stateId: 1,
                description: "DIALOGUE+3 きゃにめ",
                amount: 66800,
                categoryId: "01JNB8PFPXAC808XH263PS7TW9",
                date: "2025-02-20T00:00:00Z"
            },
        ]
    };
};
