import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Card,
  CardContent,
  Container,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  IconButton,
  Snackbar,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Typography,
  Paper,
  Alert,
} from '@mui/material';
import {
  Add as AddIcon,
  Delete as DeleteIcon,
  Edit as EditIcon,
  Home as HomeIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { getLinks, addLink, updateLink, deleteLink, Link as LinkType } from '../services/tauri-api';

const Manage: React.FC = () => {
  const [links, setLinks] = useState<LinkType[]>([]);
  const [loading, setLoading] = useState(true);
  const [openAddDialog, setOpenAddDialog] = useState(false);
  const [openEditDialog, setOpenEditDialog] = useState(false);
  const [openDeleteDialog, setOpenDeleteDialog] = useState(false);
  const [currentLink, setCurrentLink] = useState<LinkType>({ id: 0, name: '', url: '' });
  const [newLink, setNewLink] = useState({ name: '', url: '' });
  const [message, setMessage] = useState({ text: '', severity: 'success' as 'success' | 'error' });
  const [openSnackbar, setOpenSnackbar] = useState(false);
  const navigate = useNavigate();

  // 加载链接列表
  const fetchLinks = async () => {
    try {
      setLoading(true);
      const data = await getLinks();
      setLinks(data);
    } catch (error) {
      console.error('Failed to fetch links:', error);
      showMessage('加载链接失败', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLinks();
  }, []);

  // 显示消息
  const showMessage = (text: string, severity: 'success' | 'error') => {
    setMessage({ text, severity });
    setOpenSnackbar(true);
  };

  // 处理添加链接
  const handleAddLink = async () => {
    try {
      if (!newLink.name.trim() || !newLink.url.trim()) {
        showMessage('名称和链接不能为空', 'error');
        return;
      }

      await addLink(newLink.name, newLink.url);
      fetchLinks();
      setNewLink({ name: '', url: '' });
      setOpenAddDialog(false);
      showMessage('新增节目成功！', 'success');
    } catch (error) {
      console.error('Failed to add link:', error);
      showMessage('新增节目失败', 'error');
    }
  };

  // 处理更新链接
  const handleUpdateLink = async () => {
    try {
      if (!currentLink.name.trim() || !currentLink.url.trim()) {
        showMessage('名称和链接不能为空', 'error');
        return;
      }

      await updateLink(currentLink.id, currentLink.name, currentLink.url);
      fetchLinks();
      setOpenEditDialog(false);
      showMessage('更新节目成功！', 'success');
    } catch (error) {
      console.error('Failed to update link:', error);
      showMessage('更新节目失败', 'error');
    }
  };

  // 处理删除链接
  const handleDeleteLink = async () => {
    try {
      await deleteLink(currentLink.id);
      fetchLinks();
      setOpenDeleteDialog(false);
      showMessage('删除节目成功！', 'success');
    } catch (error) {
      console.error('Failed to delete link:', error);
      showMessage('删除节目失败', 'error');
    }
  };

  return (
    <Container maxWidth="lg">
      <Box sx={{ mt: 4, mb: 4 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
          <Typography variant="h3" component="h1" gutterBottom>
            管理电视直播节目
          </Typography>
          <Button
            variant="contained"
            color="primary"
            startIcon={<HomeIcon />}
            onClick={() => navigate('/')}
          >
            返回首页
          </Button>
        </Box>

        <Card>
          <CardContent>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
              <Typography variant="h6" gutterBottom>
                节目列表
              </Typography>
              <Button
                variant="contained"
                color="success"
                startIcon={<AddIcon />}
                onClick={() => setOpenAddDialog(true)}
              >
                添加节目
              </Button>
            </Box>

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
                      <TableCell sx={{ color: 'white', fontWeight: 'bold' }}>操作</TableCell>
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
                        <TableCell>{link.url}</TableCell>
                        <TableCell>
                          <Box sx={{ display: 'flex', gap: 1 }}>
                            <IconButton
                              color="primary"
                              onClick={() => {
                                setCurrentLink(link);
                                setOpenEditDialog(true);
                              }}
                            >
                              <EditIcon />
                            </IconButton>
                            <IconButton
                              color="error"
                              onClick={() => {
                                setCurrentLink(link);
                                setOpenDeleteDialog(true);
                              }}
                            >
                              <DeleteIcon />
                            </IconButton>
                          </Box>
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

      {/* 添加链接对话框 */}
      <Dialog open={openAddDialog} onClose={() => setOpenAddDialog(false)}>
        <DialogTitle>添加新节目</DialogTitle>
        <DialogContent>
          <Box sx={{ mt: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
            <TextField
              label="节目名称"
              variant="outlined"
              fullWidth
              value={newLink.name}
              onChange={(e) => setNewLink({ ...newLink, name: e.target.value })}
            />
            <TextField
              label="直播链接"
              variant="outlined"
              fullWidth
              value={newLink.url}
              onChange={(e) => setNewLink({ ...newLink, url: e.target.value })}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenAddDialog(false)}>取消</Button>
          <Button onClick={handleAddLink} variant="contained" color="success">
            添加
          </Button>
        </DialogActions>
      </Dialog>

      {/* 编辑链接对话框 */}
      <Dialog open={openEditDialog} onClose={() => setOpenEditDialog(false)}>
        <DialogTitle>编辑节目</DialogTitle>
        <DialogContent>
          <Box sx={{ mt: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
            <TextField
              label="节目名称"
              variant="outlined"
              fullWidth
              value={currentLink.name}
              onChange={(e) => setCurrentLink({ ...currentLink, name: e.target.value })}
            />
            <TextField
              label="直播链接"
              variant="outlined"
              fullWidth
              value={currentLink.url}
              onChange={(e) => setCurrentLink({ ...currentLink, url: e.target.value })}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenEditDialog(false)}>取消</Button>
          <Button onClick={handleUpdateLink} variant="contained" color="primary">
            更新
          </Button>
        </DialogActions>
      </Dialog>

      {/* 删除链接对话框 */}
      <Dialog open={openDeleteDialog} onClose={() => setOpenDeleteDialog(false)}>
        <DialogTitle>确认删除</DialogTitle>
        <DialogContent>
          <Typography variant="body1">
            确定要删除节目 "{currentLink.name}" 吗？此操作不可恢复。
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDeleteDialog(false)}>取消</Button>
          <Button onClick={handleDeleteLink} variant="contained" color="error">
            删除
          </Button>
        </DialogActions>
      </Dialog>

      {/* 消息提示 */}
      <Snackbar
        open={openSnackbar}
        autoHideDuration={6000}
        onClose={() => setOpenSnackbar(false)}
      >
        <Alert
          onClose={() => setOpenSnackbar(false)}
          severity={message.severity}
          sx={{ width: '100%' }}
        >
          {message.text}
        </Alert>
      </Snackbar>
    </Container>
  );
};

export default Manage;
