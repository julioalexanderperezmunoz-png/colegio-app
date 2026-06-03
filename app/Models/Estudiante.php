<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Estudiante extends Model
{
    protected $fillable = ['grado_id', 'nombres', 'dni', 'foto'];

    public function grado()
    {
        return $this->belongsTo(Grado::class);
    }
}