<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Pemicu;
use Illuminate\Database\Seeder;

class DummyDataSeeder extends Seeder
{
    public function run(): void
    {
        // User dummy
        User::create([
            'name' => 'Demas Axel',
            'email' => 'demas@example.com',
            'password' => bcrypt('password123'),
        ]);

        // Pemicu dummy
        $pemicus = [
            ['nama' => 'Kurang Tidur', 'ikon' => '😴', 'kategori' => 'aktivitas'],
            ['nama' => 'Konflik Sosial', 'ikon' => '😤', 'kategori' => 'sosial'],
            ['nama' => 'Lingkungan Bising', 'ikon' => '🔊', 'kategori' => 'lingkungan'],
            ['nama' => 'Banyak Tugas', 'ikon' => '📚', 'kategori' => 'aktivitas'],
            ['nama' => 'Olahraga', 'ikon' => '🏃', 'kategori' => 'aktivitas'],
            ['nama' => 'Kurang Makan', 'ikon' => '🍽️', 'kategori' => 'aktivitas'],
            ['nama' => 'Hujan', 'ikon' => '🌧️', 'kategori' => 'lingkungan'],
            ['nama' => 'Support Teman', 'ikon' => '💪', 'kategori' => 'sosial'],
        ];

        foreach ($pemicus as $pemicu) {
            Pemicu::create($pemicu);
        }
    }
}