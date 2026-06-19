<?php

namespace Database\Seeders;

use App\Models\Content;
use Illuminate\Database\Seeder;

class ContentSeeder extends Seeder
{
    public function run(): void
    {
        $contents = [
            [
                'title' => 'Kekuatan dari Kebiasaan Kecil',
                'description' => 'Bagaimana mencatat hal kecil setiap hari dapat mengubah kesehatan mentalmu.',
                'full_content' => 'Lorem ipsum dolor sit amet...',
                'type' => 'ARTIKEL',
                'is_premium' => false,
            ],
            [
                'title' => 'Rutinitas Malam untuk Tidur Berkualitas',
                'description' => 'Coba teknik peregangan otot ringan sebelum tidur untuk kualitas istirahat lebih baik.',
                'full_content' => 'Lorem ipsum dolor sit amet...',
                'type' => 'ARTIKEL',
                'is_premium' => false,
            ],
            [
                'title' => '5 Menit Teknik Pernapasan',
                'description' => 'Video panduan pernapasan dalam untuk menenangkan pikiran dan tubuh.',
                'full_content' => 'https://example.com/video1',
                'type' => 'VIDEO',
                'video_url' => 'https://example.com/video1',
                'is_premium' => false,
            ],
            [
                'title' => 'Langkah Kecil Berarti Besar',
                'description' => '"Perjalanan seribu mil dimulai dengan satu langkah kecil." - Lao Tzu',
                'full_content' => 'Perjalanan seribu mil dimulai dengan satu langkah kecil.',
                'type' => 'KUTIPAN',
                'is_premium' => false,
            ],
            [
                'title' => 'Memahami Hormon Kebahagiaan',
                'description' => 'Mengenal Dopamin, Serotonin, Endorfin, dan Oksitosin.',
                'full_content' => 'https://example.com/video2',
                'type' => 'VIDEO',
                'video_url' => 'https://example.com/video2',
                'is_premium' => true,
            ],
            [
                'title' => 'Self-Compassion',
                'description' => 'Belajar untuk lebih baik kepada diri sendiri adalah kunci kesehatan mental.',
                'full_content' => 'Lorem ipsum dolor sit amet...',
                'type' => 'ARTIKEL',
                'is_premium' => true,
            ],
            [
                'title' => 'Meditasi 10 Menit',
                'description' => 'Panduan meditasi singkat untuk memulai hari dengan tenang.',
                'full_content' => 'https://example.com/video3',
                'type' => 'VIDEO',
                'video_url' => 'https://example.com/video3',
                'is_premium' => true,
            ],
            [
                'title' => 'Ketenangan Bukan Berarti Hening',
                'description' => '"Ketenangan bukan berarti tidak ada badai, melainkan tetap tenang di tengah badai."',
                'full_content' => 'Ketenangan bukan berarti tidak ada badai...',
                'type' => 'KUTIPAN',
                'is_premium' => true,
            ],
            [
                'title' => 'Mindfulness untuk Pemula',
                'description' => 'Panduan lengkap mindfulness untuk memulai perjalanan kesehatan mental.',
                'full_content' => 'Lorem ipsum dolor sit amet...',
                'type' => 'ARTIKEL',
                'is_premium' => true,
            ],
            [
                'title' => 'Yoga untuk Ketenangan',
                'description' => 'Gerakan yoga sederhana untuk mengurangi stres.',
                'full_content' => 'https://example.com/video4',
                'type' => 'VIDEO',
                'video_url' => 'https://example.com/video4',
                'is_premium' => true,
            ],
        ];

        foreach ($contents as $content) {
            Content::create($content);
        }
    }
}