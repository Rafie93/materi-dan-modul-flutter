<?php

namespace App\Controllers\Api;

use App\Models\UmkmModel;
use CodeIgniter\RESTful\ResourceController;

class UmkmController extends ResourceController
{
    // GET API ALL DATA UMKM
    public function index()
    {
       
        $umkmModel = new UmkmModel();
        $umkm = $umkmModel->findAll();
        
        return $this->respond([
            'success' => true,
            'message' => 'Data UMKM berhasil diambil',
            'data' => $umkm
        ], 200);
    }

    // POST API UMKM
    public function create()
    {
        $validation = \Config\Services::validation();
        $rules = [
            'nama_umkm' => 'required|min_length[3]|is_unique[umkm.nama_umkm]',
            'kategori'  => 'permit_empty|string',
            'pemilik'   => 'permit_empty|string',
            'alamat'    => 'permit_empty|string',
            'kontak'    => 'permit_empty|string'
        ];
    
        $data = $this->request->getPost();
    
        if (!$validation->setRules($rules)->run($data)) {
            return $this->respond([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validation->getErrors()
            ], 400);
        }
    
        $umkmModel = new UmkmModel();
    
        $insertedId = $umkmModel->insert($data);
    
        if ($insertedId === false) {
            return $this->respond([
                'success' => false,
                'message' => 'Gagal menambahkan data UMKM',
                'errors'  => $umkmModel->errors()
            ], 500);
        }
    
        $newData = $umkmModel->find($insertedId);
        return $this->respondCreated([
            'success' => true,
            'message' => 'Data UMKM berhasil ditambahkan',
            'data'    => $newData
        ]);
    }
    

    // PUT API UMKM
    public function update($id = null)
    {
        $data = $this->request->getRawInput();
        $umkmModel = new UmkmModel();
        $umkm = $umkmModel->update($id, $data);

        return $this->respond([
            'success' => true,
            'message' => 'Data UMKM berhasil diubah',
            'data' => $umkm
        ], 200);
    }

    // DELETE API UMKM
    public function delete($id = null)
    {
        $umkmModel = new UmkmModel();
        $data = $umkmModel->find($id);
        if (!$data) {
            return $this->respond([
                'success' => false,
                'message' => 'Data UMKM tidak ditemukan',
            ], 404);
        }
        $umkmModel->delete($id);
       
        return $this->respond([
            'success' => true,
            'message' => 'Data UMKM berhasil dihapus',
            'data' => $data
        ], 200);
    }

    // OPTIONS method for CORS preflight requests
    public function options()
    {
        return $this->respond('', 200);
    }

}
