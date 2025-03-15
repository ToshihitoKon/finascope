import type * as apitype from './types';
import { type ColumnDef } from '@tanstack/table-core';

const States = [
    { id: 1, label: "予定" },
    { id: 2, label: "支払済" },
    { id: 3, label: "検討中" },
    { id: 4, label: "やめた" },
]

const RecordTypes = [
    { id: 1, label: "支出" },
    { id: 2, label: "収入" },
    { id: 3, label: "何？" },
]

const RecordColumnDef: ColumnDef<apitype.RecordsResponse>[] = [
    {
        accessorKey: 'typeLabel',
        header: 'Type'
    },
    {
        accessorKey: 'name',
        header: 'Name'
    },
    {
        accessorKey: 'amount',
        header: 'Amount'
    },
    {
        accessorKey: 'stateLabel',
        header: 'State'
    },
    {
        accessorKey: 'description',
        header: 'Description'
    },
    {
        accessorKey: 'categoryLabel',
        header: 'Category'
    },
    {
        accessorKey: 'date',
        header: 'Date'
    }
];

export { States, RecordTypes, RecordColumnDef }
