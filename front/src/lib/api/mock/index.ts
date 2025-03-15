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
                name: "DIALOGUE+ カクノゴトキロックンロールチケ",
                id: "01JNBK19Q5E0CQC3A9D7QS56Z7",
                typeLabel: "支出",
                stateLabel: "支払済",
                description: "全通",
                amount: 66800,
                categoryLabel: "DIALOGUE+",
                date: "2025-02-20T00:00:00Z"
            },
            {
                name: "DIALOGUE+3 きゃにめ版",
                id: "01JPCSYGCCMKYC4YMP7Z6ZB3K9",
                typeLabel: "支出",
                stateLabel: "支払済",
                description: "81直筆サインあたった神回",
                amount: 8800,
                categoryLabel: "DIALOGUE+",
                date: "2025-02-20T00:00:00Z"
            }
        ]
    };
};
