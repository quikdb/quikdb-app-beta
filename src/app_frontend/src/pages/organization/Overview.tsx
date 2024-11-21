import { Button } from '@/components/ui/button';
import { Link } from 'react-router-dom';

const Overview = () => {
  return (
    <div className='mt-10 space-y-8'>
      <div className='flex justify-between'>
        <div className='flex flex-col gap-1'>
          <p className='font-satoshi_medium text-3xl'>Organizations</p>
          <p className='font-satoshi_light text-base text-gray-400'>Unlock API Access with Personal Tokens</p>
        </div>
        <div>
          <Link to='/organizations/create-organization' className='container'>
            <Button size='lg' className='bg-gradient w-fit px-4 text-[#0F1407]'>
              Create new organization
            </Button>
          </Link>
        </div>
      </div>
      <div className='bg-blackoff rounded-lg mt-7 flex flex-col justify-center items-center gap-10 h-[70vh]'>
        <div className='flex flex-col items-center gap-2'>
          <img src='/images/empty_org.png' alt='empty_box' />
          <p className='text-base mb-[-5px]'>No Organization Available</p>
          <p className='text-sm font-satoshi_light text-gray-400'>List of organizations will appear here</p>
        </div>
      </div>
    </div>
  );
};

export default Overview;
