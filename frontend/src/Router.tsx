import { Route, Routes } from 'react-router-dom';
import Home from './pages/Home';
import Login from './pages/Login';
import Profile from './pages/Profile';
import RouteGuard from './guards/RouteGuard'


const Router = () => {
   return (
     <>
       <Routes>
         <Route index element={<Home />} />
         <Route path="/" element={<Home />} />
         <Route path="login" element={<Login />} />
         <Route element={<RouteGuard />}>
           <Route path="profile" element={<Profile />} />
         </Route>
         <Route path="*" element={<p>There's nothing here: 404!</p>} />
       </Routes>
     </>
   );
 };
  
  export default Router;