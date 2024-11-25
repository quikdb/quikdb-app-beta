"use client"

import * as React from "react"
import {
    ColumnDef,
    ColumnFiltersState,
    SortingState,
    VisibilityState,
    flexRender,
    getCoreRowModel,
    getFilteredRowModel,
    getPaginationRowModel,
    getSortedRowModel,
    useReactTable,
} from "@tanstack/react-table"
import { ChevronDown } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import {
    DropdownMenu,
    DropdownMenuCheckboxItem,
    DropdownMenuContent,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Input } from "@/components/onboarding"
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table"
import { Link } from "react-router-dom"

const data: Project[] = [
    {
        project: "UrbanLfe Suite",
        date: "Jun 24 2024 11:42:03",
        creator: "Joan Nobei",
        databases: "0 clusters",
        users: "6 users",
    },
    {
        project: "UrbanLfe Suite",
        date: "Jun 24 2024 11:42:03",
        creator: "Joan Nobei",
        databases: "0 clusters",
        users: "6 users",
    },
    {
        project: "UrbanLfe Suite",
        date: "Jun 24 2024 11:42:03",
        creator: "Joan Nobei",
        databases: "0 clusters",
        users: "6 users",
    },
    {
        project: "UrbanLfe Suite",
        date: "Jun 24 2024 11:42:03",
        creator: "Joan Nobei",
        databases: "0 clusters",
        users: "6 users",
    },
    {
        project: "UrbanLfe Suite",
        date: "Jun 24 2024 11:42:03",
        creator: "Joan Nobei",
        databases: "0 clusters",
        users: "6 users",
    },
    {
        project: "UrbanLfe Suite",
        date: "Jun 24 2024 11:42:03",
        creator: "Joan Nobei",
        databases: "0 clusters",
        users: "6 users",
    },
    {
        project: "UrbanLfe Suite",
        date: "Jun 24 2024 11:42:03",
        creator: "Joan Nobei",
        databases: "0 clusters",
        users: "6 users",
    },
]

export type Project = {
    project: string
    date: string
    creator: string
    databases: string
    users: string
}

export const columns: ColumnDef<Project>[] = [
    {
        id: "select",
        header: ({ table }) => (
            <Checkbox className="ml-5"
                checked={
                    table.getIsAllPageRowsSelected()
                        ? true
                        : table.getIsSomePageRowsSelected()
                            ? "indeterminate"
                            : false
                }
                onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
                aria-label="Select all"
            />
        ),
        cell: ({ row }) => (
            <Checkbox className="ml-5"
                checked={row.getIsSelected()}
                onCheckedChange={(value) => row.toggleSelected(!!value)}
                aria-label="Select row"
            />
        ),
        enableSorting: false,
        enableHiding: false,
    },
    {
        accessorKey: "project",
        header: "Project Name",
        cell: ({ row }) => (
            <div>{row.getValue("project")}</div>
        ),
    },
    {
        accessorKey: "date",
        header: "Date Created",
        cell: ({ row }) => (
            <div>{row.getValue("date")}</div>
        ),
    },
    {
        accessorKey: "creator",
        header: "Created by",
        cell: ({ row }) => (
            <div>{row.getValue("creator")}</div>
        ),
    },
    {
        accessorKey: "databases",
        header: "Databases",
        cell: ({ row }) => (
            <div>{row.getValue("databases")}</div>
        ),
    },
    {
        accessorKey: "users",
        header: "Users",
        cell: ({ row }) => (
            <div>{row.getValue("users")}</div>
        ),
    },
]

export function ProjectTable() {
    const [sorting, setSorting] = React.useState<SortingState>([])
    const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>(
        []
    )
    const [columnVisibility, setColumnVisibility] =
        React.useState<VisibilityState>({})
    const [rowSelection, setRowSelection] = React.useState({})

    const table = useReactTable({
        data,
        columns,
        onSortingChange: setSorting,
        onColumnFiltersChange: setColumnFilters,
        getCoreRowModel: getCoreRowModel(),
        getPaginationRowModel: getPaginationRowModel(),
        getSortedRowModel: getSortedRowModel(),
        getFilteredRowModel: getFilteredRowModel(),
        onColumnVisibilityChange: setColumnVisibility,
        onRowSelectionChange: setRowSelection,
        state: {
            sorting,
            columnFilters,
            columnVisibility,
            rowSelection,
        },
    })

    return (
        <div className="w-full">
            <div className="flex items-center pt-7 pb-5">
                <Input
                    placeholder="Filter emails..."
                    value={(table.getColumn("email")?.getFilterValue() as string) ?? ""}
                    onChange={(event) =>
                        table.getColumn("email")?.setFilterValue(event.target.value)
                    }
                    className="max-w-sm h-11"
                />
                <DropdownMenu>
                    <DropdownMenuTrigger asChild className="h-11">
                        <Button className="ml-auto">
                            Columns <ChevronDown />
                        </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="bg-[#111015] text-white border-gray-600">
                        {table
                            .getAllColumns()
                            .filter((column) => column.getCanHide())
                            .map((column) => {
                                return (
                                    <DropdownMenuCheckboxItem
                                        key={column.id}
                                        className="capitalize"
                                        checked={column.getIsVisible()}
                                        onCheckedChange={(value) =>
                                            column.toggleVisibility(!!value)
                                        }
                                    >
                                        {column.id}
                                    </DropdownMenuCheckboxItem>
                                )
                            })}
                    </DropdownMenuContent>
                </DropdownMenu>
            </div>
            <div className="rounded-md border border-[#242527]">
                <Table>
                    <TableHeader>
                        {table.getHeaderGroups().map((headerGroup) => (
                            <TableRow key={headerGroup.id}>
                                {headerGroup.headers.map((header) => {
                                    return (
                                        <TableHead key={header.id} className="py-4">
                                            {header.isPlaceholder
                                                ? null
                                                : flexRender(
                                                    header.column.columnDef.header,
                                                    header.getContext()
                                                )}
                                        </TableHead>
                                    )
                                })}
                            </TableRow>
                        ))}
                    </TableHeader>
                    <TableBody className="font-satoshi_light">
                        {table.getRowModel().rows?.length ? (
                            table.getRowModel().rows.map((row) => (
                                <TableRow
                                    key={row.id}
                                    data-state={row.getIsSelected() && "selected"}
                                >
                                    {row.getVisibleCells().map((cell) => (
                                        <TableCell key={cell.id} className="py-6">
                                            {flexRender(
                                                cell.column.columnDef.cell,
                                                cell.getContext()
                                            )}
                                        </TableCell>
                                    ))}
                                </TableRow>
                            ))
                        ) : (
                            <TableRow>
                                <TableCell
                                    colSpan={columns.length}
                                    className="h-24 text-center"
                                >
                                    No results.
                                </TableCell>
                            </TableRow>
                        )}
                    </TableBody>
                </Table>
            </div>
            <div className="flex items-center justify-end space-x-2 py-4">
                <div className="flex-1 text-sm text-muted-foreground">
                    {table.getFilteredSelectedRowModel().rows.length} of{" "}
                    {table.getFilteredRowModel().rows.length} row(s) selected.
                </div>
                <div className="space-x-2">
                    <Button
                        size="sm"
                        onClick={() => table.previousPage()}
                        disabled={!table.getCanPreviousPage()}
                    >
                        Previous
                    </Button>
                    <Link to="/dashboard/project_1" >
                        <Button
                            size="sm"
                            onClick={() => table.nextPage()}
                            disabled={!table.getCanNextPage()}
                        >
                            Next
                        </Button>
                    </Link>
                </div>
            </div>
        </div>
    )
}