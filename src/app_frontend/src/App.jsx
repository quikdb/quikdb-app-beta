import { useState } from 'react';
// import { app_backend } from 'declarations/app_backend';

function App() {

  return (
    <main className='bg-blacko text-white min-h-screen p-10 py-7'>
      <header>
        <p className='text-gradient'>quikdb</p>
      </header>
      <div className='container mx-auto p-4'>
        <div className='text-center'>
          <p>Create an account</p>
          <p className='text-sm font-light text-gray-200'>Enter your email to sign up for this app</p>
        </div>
      </div>
    </main>
  );
}

export default App;
