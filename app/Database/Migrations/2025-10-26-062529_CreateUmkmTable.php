<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class CreateUmkmTable extends Migration
{
    public function up()
    {
        $this->forge->addField([
            'id'            => ['type' => 'INT', 'constraint' => 11, 'auto_increment' => true],
            'nama_umkm'     => ['type' => 'VARCHAR', 'constraint' => 100],
            'pemilik'       => ['type' => 'VARCHAR', 'constraint' => 100, 'null' => true],
            'alamat'        => ['type' => 'TEXT', 'null' => true],
            'kategori'      => ['type' => 'VARCHAR', 'constraint' => 50, 'null' => true],
            'kontak'        => ['type' => 'VARCHAR', 'constraint' => 20, 'null' => true],
            'created_at'    => ['type' => 'DATETIME', 'null' => true],
            'updated_at'    => ['type' => 'DATETIME', 'null' => true],
        ]);

        $this->forge->addKey('id', true);
        $this->forge->createTable('umkm');
    }

    public function down()
    {
        $this->forge->dropTable('umkm');
    }
}
