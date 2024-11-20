import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

const NewOrganization = () => {
  return (
    <div className='mt-10 px-6'>
      {/* Header */}
      <div className='flex flex-col items-center mb-8'>
        <div className='flex flex-col gap-1'>
          <p className='font-satoshi_medium text-3xl'>Create Organization</p>
          <p className='font-satoshi_light text-base text-gray-400'>Lorem ipsum lorem ipsum lorem ipsum lorem ipsum</p>
        </div>
      </div>

      {/* Form Section */}
      <div className=' p-8 flex flex-col gap-6'>
        <div>
          <label className='block text-gray-400 text-sm mb-2'>Organization Name</label>
          <Input type='text' placeholder='' className='w-full p-6 bg-black rounded-md text-white' />
        </div>

        <div>
          <label className='block text-gray-400 text-sm mb-2'>Organization Details</label>
          <Input type='text' placeholder='' className='w-full p-6 bg-black rounded-md text-white' />
        </div>

        {/* Create Button */}
        <Button className='bg-gradient w-fit px-6 py-2 mx-auto mt-4 text-[#0F1407]'>Create</Button>
      </div>
    </div>
  );
};

export default NewOrganization;
