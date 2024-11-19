import { Link } from 'react-router-dom';
import { Button } from './ui/button';
import { BarChartIcon, BookmarkFilledIcon, Crosshair2Icon, DashboardIcon, FileTextIcon, GearIcon, ListBulletIcon, PersonIcon } from '@radix-ui/react-icons';
import { HeadphonesIcon, LogOutIcon } from 'lucide-react';

const Sidebar = () => {

    const navigation = [
        { name: 'Overview', to: '', icon: <DashboardIcon /> },
        { name: 'Projects', to: 'new-record', icon: <FileTextIcon /> },
        { name: 'User Management', to: 'manage-staff', icon: <PersonIcon /> },
        { name: 'Audit Logs', to: 'notifications', icon: <ListBulletIcon /> },
        { name: 'Analytics', to: 'notifications', icon: <BarChartIcon /> },
        { name: 'Access Token', to: 'notifications', icon: <Crosshair2Icon /> },
        { name: 'Rewards', to: 'notifications', icon: <BookmarkFilledIcon /> },
        { name: 'Settings', to: 'notifications', icon: <GearIcon /> },
    ].filter(Boolean);

    return (
        <div className='bg-blackoff w-[18%] border-r-2 border-r-[#1B1C1F] fixed hidden lg:flex flex-col items-center justify-start p-10 py-20 min-h-screen h-full'>
            <div className="flex flex-col justify-between h-full">
                <div>
                    <Link to="/" className="font-satoshi_medium text-gradient text-2xl pl-10">quikDB</Link>
                    <div className='flex flex-col gap-2 mt-16'>
                        {navigation.map((item) => {
                            return (
                                <Link
                                    key={item.name}
                                    to={item.to}
                                    className={`flex items-center gap-3 rounded-lg py-2 px-8 text-sm leading-7
                                ${location.pathname === `dashboard/${item.to}` ? 'bg-blue-800' : 'hover:bg-blue-800'}`}
                                >
                                    {item.icon}
                                    {item.name}
                                </Link>
                            )
                        })}
                    </div>
                </div>
                <div className="py-6 mt-20 flex flex-col gap-2">
                    <Link to="/"><Button size="lg"><HeadphonesIcon /> Support</Button></Link>
                    <Link to="/"><Button size="lg"><LogOutIcon /> Logout</Button></Link>
                </div>
            </div>
        </div>
    );
};

export default Sidebar