const ApiBaseUrl = "/api/v1"

const States = [
    { id: 1, label: "予定" },
    { id: 2, label: "支払済" },
    { id: 3, label: "考え中" },
    { id: 4, label: "やめた" },
]

const RecordTypes = [
    { id: 1, label: "支出" },
    { id: 2, label: "収入" },
    { id: 3, label: "何？" },
]

export { ApiBaseUrl, States, RecordTypes }
