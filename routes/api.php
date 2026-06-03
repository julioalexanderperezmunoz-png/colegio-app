<?php

use App\Http\Controllers\Api\GradoController;
use App\Http\Controllers\Api\EstudianteController;
use Illuminate\Support\Facades\Route;

Route::apiResource('grados', GradoController::class);
Route::apiResource('estudiantes', EstudianteController::class);