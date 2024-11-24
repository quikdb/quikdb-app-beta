import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table';
import { useState } from 'react';

const ListOrganizations = () => {
  const organizations = [
    {
      id: 1,
      name: "Joannobei's Org.",
      roles: '2024-01-15 10:23 AM',
      dateCreated: '2024-01-15',
      lastUpdated: '2025-01-15',
      storage: '200',
      clusters: '0 clusters',
      accessLevel: 'Read-Write',
    },
    {
      id: 2,
      name: "Joannobei's Org.",
      roles: '2024-01-15 10:23 AM',
      dateCreated: '2024-01-15',
      lastUpdated: '2025-01-15',
      storage: '100',
      clusters: '0 clusters',
      accessLevel: 'Read-Write',
    },
    {
      id: 3,
      name: "Joannobei's Org.",
      roles: '2024-01-15 10:23 AM',
      dateCreated: '2024-01-15',
      lastUpdated: '2025-01-15',
      storage: '200',
      clusters: '0 clusters',
      accessLevel: 'Read-Write',
    },
    {
      id: 4,
      name: "Joannobei's Org.",
      roles: '2024-01-15 10:23 AM',
      dateCreated: '2024-01-15',
      lastUpdated: '2025-01-15',
      storage: '100',
      clusters: '0 clusters',
      accessLevel: 'Read-Write',
    },
    {
      id: 5,
      name: "Joannobei's Org.",
      roles: '2024-01-15 10:23 AM',
      dateCreated: '2024-01-15',
      lastUpdated: '2025-01-15',
      storage: '0',
      clusters: '0 clusters',
      accessLevel: 'Read-Write',
    },
  ];

  const [selectedOrganizations, setSelectedOrganizations] = useState<number[]>([]);

  const handleCheckboxChange = (id: number) => {
    setSelectedOrganizations((prev) =>
      prev.includes(id) ? prev.filter((orgId) => orgId !== id) : [...prev, id]
    );
  };

  const handleSelectAllChange = () => {
    if (selectedOrganizations.length === organizations.length) {
      setSelectedOrganizations([]);
    } else {
      setSelectedOrganizations(organizations.map((org) => org.id));
    }
  };

  return (
    <div className="mt-10 px-6">
      {/* Page Header */}
      <div className="flex justify-between items-center mb-6">
        <div>
          <p className="font-satoshi_medium text-3xl text-white">Organizations</p>
          <p className="font-satoshi_light text-base text-gray-400">
            Unlock API Access with Personal Tokens
          </p>
        </div>
        <Link to="/organizations/create-organization">
          <Button size="lg" className="bg-gradient w-fit px-4 text-[#0F1407]">
            Create new organization
          </Button>
        </Link>
      </div>

      {/* Search and Filter Section */}
      <div className="flex items-center justify-between mb-4">
        <Input
          type="text"
          placeholder="Search by project name..."
          className="w-full p-3 bg-[#1F2123] text-white rounded-md"
        />
        <Button className="ml-4 bg-[#2B2D30] text-gray-300 p-2 px-6 rounded-md">
          Filter
        </Button>
      </div>

      {/* Organizations Table */}
      <div className="rounded-md border border-[#242527] bg-[#1F2123] text-white">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="py-4 text-left">
                <input
                  type="checkbox"
                  checked={selectedOrganizations.length === organizations.length}
                  onChange={handleSelectAllChange}
                  className="w-4 h-4 rounded border-gray-300 text-primary focus:ring-0"
                />
              </TableHead>
              <TableHead className="py-4 text-left">Organization Name</TableHead>
              <TableHead className="text-left">Roles</TableHead>
              <TableHead className="text-left">Date Created</TableHead>
              <TableHead className="text-left">Last Updated Date</TableHead>
              <TableHead className="text-left">Storage Size (GB)</TableHead>
              <TableHead className="text-left">Access Level</TableHead>
              <TableHead className="text-left">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {organizations.map((org) => (
              <TableRow key={org.id}>
                <TableCell>
                  <input
                    type="checkbox"
                    checked={selectedOrganizations.includes(org.id)}
                    onChange={() => handleCheckboxChange(org.id)}
                    className="w-4 h-4 rounded border-gray-300 text-primary focus:ring-0"
                  />
                </TableCell>
                <TableCell>{org.name}</TableCell>
                <TableCell>{org.roles}</TableCell>
                <TableCell>{org.dateCreated}</TableCell>
                <TableCell>{org.lastUpdated}</TableCell>
                <TableCell>{org.storage}</TableCell>
                <TableCell>{org.accessLevel}</TableCell>
                <TableCell className="flex space-x-2">
                  <Link to={`/organizations/${org.id}/edit`}>
                    <Button variant="ghost" className="text-gray-300 hover:text-white">
                      ✏️
                    </Button>
                  </Link>
                  <Button
                    variant="ghost"
                    className="text-red-400 hover:text-red-600"
                    onClick={() => alert('Delete action triggered')}
                  >
                    🗑️
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      <div className="flex justify-between items-center mt-6 text-gray-300">
        <Button variant="ghost" className="text-sm">
          ← Previous
        </Button>
        <div className="flex space-x-2">
          {[1, 2, 3, '...', 9, 10].map((page, index) => (
            <Button
              key={index}
              variant={page === 1 ? 'default' : 'ghost'}
              className={page === 1 ? 'text-white' : 'text-gray-400'}
            >
              {page}
            </Button>
          ))}
        </div>
        <Button variant="ghost" className="text-sm">
          Next →
        </Button>
      </div>
    </div>
  );
};

export default ListOrganizations;
