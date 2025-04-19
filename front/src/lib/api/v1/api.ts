import type * as apitype from "./types";
import * as consts from "./const";

const getOpts = {
    method: "GET",
    headers: {
        "Content-Type": "application/json"
    }
};

export const fetchRecords = async (): Promise<apitype.RecordsResponse> => {
    return fetch(`${consts.ApiBaseUrl}/records`, getOpts)
        .then((res) => {
            if (!res.ok) {
                throw new Error("Failed to fetch records");
            }
            return res?.json();
        })
};
