<?php

use App\Http\Controllers\ProfileController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;

// Redirigir raíz a login (evita error de Welcome.vue)
Route::get('/', function () {
    return redirect('/login');
});

// Dashboard protegido
Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

// Grupo auth
Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    // CRUD
    Route::get('/grados', function () {
        return Inertia::render('Grados/Index');
    })->name('grados');

    Route::get('/estudiantes', function () {
        return Inertia::render('Estudiantes/Index');
    })->name('estudiantes');
});

require __DIR__.'/auth.php';