import { Link, NavLink, useLocation } from "react-router-dom";
import * as React from "react";
import AppBar from "@mui/material/AppBar";
import Box from "@mui/material/Box";
import CssBaseline from "@mui/material/CssBaseline";
import Divider from "@mui/material/Divider";
import Drawer from "@mui/material/Drawer";
import IconButton from "@mui/material/IconButton";
import List from "@mui/material/List";
import ListItem from "@mui/material/ListItem";
import ListItemButton from "@mui/material/ListItemButton";
import ListItemText from "@mui/material/ListItemText";
import MenuIcon from "@mui/icons-material/Menu";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";
import Button from "@mui/material/Button";
import UserContext from "../contexts/UserContext";

type NavItem = {
    label: string;
    url: string;
    authOnly?: boolean;
    publicOnly?: boolean;
};

const drawerWidth = 240;
const navItems: NavItem[] = [
    { label: "Home", url: "/", authOnly: true },
    { label: "Profilo", url: "/profile", authOnly: true },
    { label: "Logout", url: "/logout", authOnly: true },
];

function Navigation() {
    const [mobileOpen, setMobileOpen] = React.useState(false);
    const { user } = React.useContext(UserContext);
    const location = useLocation()

    const handleDrawerToggle = () => {
        setMobileOpen((prevState) => !prevState);
    };

    const drawer = (
        <Box onClick={handleDrawerToggle} sx={{ textAlign: "center" }}>
            <Typography variant="h6" sx={{ my: 2 }}>
                Scialla
            </Typography>
            <Divider />
            <List>
                {navItems.map((item: NavItem) => {
                    if (!item?.publicOnly && item?.authOnly && !user) {
                        return null;
                    }
                    if (item?.publicOnly && user) {
                        return null;
                    }
                    return (
                        <ListItem key={item.label} disablePadding>
                            <ListItemButton sx={{ textAlign: "center" }}
                            className={location.pathname === item.url ? 'active-link': ''}>
                                <Link to={item.url.toLocaleLowerCase()}>
                                    <ListItemText
                                        primary={item.label}
                                        style={{ color: "#333" }}
                                    />
                                </Link>
                            </ListItemButton>
                        </ListItem>
                    );
                })}
            </List>
        </Box>
    );

    return (
        <Box sx={{ display: "flex" }}>
            <CssBaseline />
            <AppBar component="nav">
                <Toolbar>
                    {!user ? null : (
                        <IconButton
                            color="inherit"
                            aria-label="open drawer"
                            edge="start"
                            onClick={handleDrawerToggle}
                            sx={{ mr: 2, display: { sm: "none" } }}
                        >
                            <MenuIcon />
                        </IconButton>
                    )}

                    <Typography
                        variant="h6"
                        component="div"
                        sx={{
                            flexGrow: 1,
                            display: { sm: "block" },
                        }}
                    >
                        Scialla
                    </Typography>
                    <Box sx={{ display: { xs: "none", sm: "block" } }}>
                        {navItems.map((item: NavItem) => {
                            if (!item?.publicOnly && item?.authOnly && !user) {
                                return null;
                            }
                            if (item?.publicOnly && user) {
                                return null;
                            }
                            return (
                                <Button key={item.label} sx={{ color: "#fff" }}>
                                    <NavLink
                                        to={item.url.toLocaleLowerCase()}
                                        style={{ color: "#fff" }}
                                    >
                                        {item.label}
                                    </NavLink>
                                </Button>
                            );
                        })}
                    </Box>
                </Toolbar>
            </AppBar>
            <Box component="nav">
                <Drawer
                    variant="temporary"
                    open={mobileOpen}
                    onClose={handleDrawerToggle}
                    ModalProps={{
                        keepMounted: true, // Better open performance on mobile.
                    }}
                    sx={{
                        display: { xs: "block", sm: "none" },
                        "& .MuiDrawer-paper": {
                            boxSizing: "border-box",
                            width: drawerWidth,
                        },
                    }}
                >
                    {drawer}
                </Drawer>
            </Box>
        </Box>
    );
}

export default Navigation;
