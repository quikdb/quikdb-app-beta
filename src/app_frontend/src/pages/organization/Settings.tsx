import { Button } from '@/components/ui/button';

const Settings = () => {
  return (
    <div className='mt-10 px-6'>
      {/* Header */}
      <div className='flex flex-col items-center mb-8'>
        <div className='flex flex-col gap-1'>
          <p className='font-satoshi_medium text-3xl'>Manage Settings</p>
        </div>
      </div>

      {/* Settings Options */}
      <div className='p-8 flex flex-col gap-4'>
        {[
          { label: 'Manage members', description: 'Invite, remove, and assign roles to members.' },
          { label: 'API keys', description: '' },
          { label: 'Webhooks', description: '' },
          { label: 'Audit log', description: '' },
        ].map((item, index) => (
          <div key={index} className='flex justify-between items-center p-4 bg-black text-white rounded-lg'>
            <div>
              <p className='font-satoshi_medium text-lg'>{item.label}</p>
              {item.description && <p className='text-sm text-gray-400'>{item.description}</p>}
            </div>
            <Button className='p-2 bg-gray-800 text-white rounded-md'>{'>'}</Button>
          </div>
        ))}{' '}
        {/* Save Button */}
        <Button className='bg-gradient w-fit px-6 py-2 mx-auto mt-4 text-[#0F1407]'>Save</Button>
      </div>
    </div>
  );
};

export default Settings;
