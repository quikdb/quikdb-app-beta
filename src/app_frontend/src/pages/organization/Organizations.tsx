import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell, TableCaption } from '@/components/ui/table';

const Organizations = () => {
  // Example data
  const organizations = [
    {
      name: 'UrbanLifeSuite',
      lastActivity: 'Jun 24, 2024 11:42:03',
      status: 'Active',
    },
    {
      name: 'TravelWise',
      lastActivity: 'Jun 24, 2024 11:42:03',
      status: 'Inactive',
    },
    {
      name: 'AutoFlow',
      lastActivity: 'Jun 24, 2024 11:42:03',
      status: 'Archived',
    },
    {
      name: 'AutoFlow',
      lastActivity: 'Jun 24, 2024 11:42:03',
      status: 'Archived',
    },
  ];

  // Helper function to return the status badge
  const renderStatusBadge = (status: string) => {
    const statusStyles = {
      Active: 'bg-green-100 text-[#12B76A]',
      Inactive: 'bg-red-100 text-[#F15046]',
      Archived: 'bg-yellow-100 text-[#FFB422]',
    };

    return <span className={`px-3 py-1 rounded-full text-sm ${statusStyles[status] || 'bg-gray-100 text-gray-700'}`}>{status}</span>;
  };

  return (
    <div className='mt-10 space-y-8'>
      {/* Page Header */}
      <div className='flex justify-between'>
        <div className='flex flex-col gap-1'>
          <p className='font-satoshi_medium text-3xl'>Organizations</p>
          <p className='font-satoshi_light text-base text-gray-400'>Unlock API Access with Personal Tokens</p>
        </div>
        <Button size='lg' className='bg-gradient w-fit px-4 text-[#0F1407]'>
          Create new organization
        </Button>
      </div>

      {/* Search and Filter Section */}
      <div className='flex items-center'>
        <Input type='text' placeholder='Search by project name...' className='w-full p-8 bg-blackoff rounded-lg' />
      </div>

      {/* Organizations Table */}
      <div className='rounded-md border border-[#242527]'>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className='py-4 text-center align-middle'>Project Name</TableHead>
              <TableHead className='text-center align-middle'>Last Activity Date</TableHead>
              <TableHead className='text-center align-middle'>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {organizations.map((org, index) => (
              <TableRow key={index}>
                <TableCell className='py-6 text-center align-middle'>{org.name}</TableCell>
                <TableCell className='text-center align-middle'>{org.lastActivity}</TableCell>
                <TableCell className='text-center align-middle'>{renderStatusBadge(org.status)}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  );
};

export default Organizations;
