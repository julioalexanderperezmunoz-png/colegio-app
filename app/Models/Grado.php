<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Grado extends Model
{
    protected $fillable = ['nombre', 'nivel'];

    public function estudiantes(): HasMany
    {
        return $this->hasMany(Estudiante::class);
    }
}