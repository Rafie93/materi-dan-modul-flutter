<?php

namespace Config;
use CodeIgniter\Config\BaseConfig;

class Cors extends BaseConfig
{
    public $aliases = [
        'csrf'    => \CodeIgniter\Filters\CSRF::class,
        'toolbar' => \CodeIgniter\Filters\DebugToolbar::class,
        'honeypot'=> \CodeIgniter\Filters\Honeypot::class,
        'cors'    => \App\Filters\Cors::class,
    ];
    public $globals = [
        'before' => [
            'cors'
        ],
        'after'  => [],
    ];
   
    public array $default = [
        'allowedOrigins' => [],
        'allowedOriginsPatterns' => [],
        'supportsCredentials' => false,
        'allowedHeaders' => [],
        'exposedHeaders' => [],
        'allowedMethods' => [],
        'maxAge' => 7200,
    ];
}
