<?php

namespace Database\Seeders;

use App\Models\Pemicu;
use Illuminate\Database\Seeder;

class PemicuSeeder extends Seeder
{
    public function run(): void
    {
        $pemicus = [
            ['nama' => 'Work', 'ikon' => '💼'],
            ['nama' => 'Study', 'ikon' => '📚'],
            ['nama' => 'Sleep', 'ikon' => '😴'],
            ['nama' => 'Exercise', 'ikon' => '💪'],
            ['nama' => 'Food', 'ikon' => '🍔'],
            ['nama' => 'Caffeine', 'ikon' => '☕'],
            ['nama' => 'Social', 'ikon' => '👥'],
            ['nama' => 'Music', 'ikon' => '🎵'],
            ['nama' => 'Nature', 'ikon' => '🌿'],
            ['nama' => 'Screen Time', 'ikon' => '📱'],
            ['nama' => 'Weather', 'ikon' => '☁️'],
            ['nama' => 'Stress', 'ikon' => '😰'],
            ['nama' => 'Relationship', 'ikon' => '💕'],
            ['nama' => 'Finance', 'ikon' => '💰'],
            ['nama' => 'Health', 'ikon' => '🏥'],
        ];

        foreach ($pemicus as $pemicu) {
            Pemicu::create($pemicu);
        }
    }
}