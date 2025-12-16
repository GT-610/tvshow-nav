import { useEffect, useState } from 'react';
import { Box, Button, Card, CardContent, Container, Link, Typography, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper } from '@mui/material';
import { Edit as EditIcon } from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { getLinks, Link as LinkType } from '../services/tauri-api';

const Home: React.FC = () => {
  const [links, setLinks] = useState<LinkType[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchLinks = async () => {
      try {
        const data = await getLinks();
        setLinks(data);
      } catch (error) {
        console.error('Failed to fetch links:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchLinks();
  }, []);

  return (
    <Container maxWidth="lg">
      <Box sx={{ mt: 4, mb: 4 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
          <Typography variant="h3" component="h1" gutterBottom>
            电视直播导航
          </Typography>
          <Button
            variant="contained"
            color="primary"
            startIcon={<EditIcon />}
            onClick={() => navigate('/manage')}
          >
            编辑节目
          </Button>
        </Box>

        <Card>
          <CardContent>
            <Typography variant="h6" gutterBottom>
              轻松跳转到您喜爱的电视台直播
            </Typography>
            
            {loading ? (
              <Typography variant="body1">加载中...</Typography>
            ) : links.length === 0 ? (
              <Typography variant="body1">暂无数据</Typography>
            ) : (
              <TableContainer component={Paper}>
                <Table sx={{ minWidth: 650 }} aria-label="电视直播链接表">
                  <TableHead>
                    <TableRow sx={{ backgroundColor: '#343a40' }}>
                      <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>#</TableCell>
                      <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>名称</TableCell>
                      <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>链接</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {links.map((link, index) => (
                      <TableRow
                        key={link.id}
                        sx={{
                          '&:nth-of-type(odd)': {
                            backgroundColor: '#f8f9fa',
                          },
                          '&:hover': {
                            backgroundColor: '#e3f2fd',
                          },
                        }}
                      >
                        <TableCell component="th" scope="row">
                          {index + 1}
                        </TableCell>
                        <TableCell>{link.name}</TableCell>
                        <TableCell>
                          <Link href={link.url} target="_blank" rel="noopener noreferrer">
                            {link.url}
                          </Link>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </TableContainer>
            )}
          </CardContent>
        </Card>
      </Box>
    </Container>
  );
};

export default Home;
