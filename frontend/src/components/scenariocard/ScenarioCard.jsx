import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardMedia from '@mui/material/CardMedia';
import Typography from '@mui/material/Typography';
import { Button, CardActionArea, CardActions } from '@mui/material';
import { NavLink } from "react-router-dom";

export default function ScenarioCard() {
  
  return (
    <Card sx={{ maxWidth: 345 }}>
      <CardActionArea>
        <CardMedia
          component="img"
          height="140"
          image="/assets/img/mimo_140.jpg"
          alt="green iguana"
        />
        <CardContent>
          <Typography gutterBottom variant="h5" component="div">
            Mimo
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Sei in grado di farti capire a gesti prima della scadenz del tempo?
          </Typography>
        </CardContent>
      </CardActionArea>
      <CardActions>
        <Button size="small" color="primary">
          <NavLink to='/mimo'>
            Gioca
          </NavLink>

        </Button>
      </CardActions>
    </Card>
  );
}