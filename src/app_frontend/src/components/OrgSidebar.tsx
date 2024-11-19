import { Link } from 'react-router-dom';
import { Button } from './ui/button';
import { BarChartIcon, BookmarkFilledIcon, Crosshair2Icon, DashboardIcon, FileTextIcon, GearIcon, ListBulletIcon, PersonIcon } from '@radix-ui/react-icons';
import { HeadphonesIcon, LogOutIcon } from 'lucide-react';

const OrgSidebar = () => {

    const navigation = [
        { name: 'Overview', to: '', icon: <DashboardIcon /> },
        { name: 'Organizations', to: 'new-record', icon: <FileTextIcon /> },
        { name: 'Invitations', to: 'manage-staff', icon: <PersonIcon /> },
        { name: 'Documentation', to: 'notifications', icon: <ListBulletIcon /> },
        { name: 'Settings', to: 'notifications', icon: <ListBulletIcon /> },
    ].filter(Boolean);

    return (
        <div className='bg-blackoff w-[18%] border-r-2 border-r-[#1B1C1F] fixed hidden lg:flex flex-col items-center justify-start p-10 py-20 min-h-screen h-full'>
            <div className="flex flex-col h-full">
                    <div className="text-gradient text-xl pl-10">quikDB</div>
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
        </div>
    );
};

export default OrgSidebar