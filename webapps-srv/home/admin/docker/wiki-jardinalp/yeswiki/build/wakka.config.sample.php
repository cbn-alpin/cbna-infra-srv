<?php
// Copy this file to "wakka.config.php"
// wakka.config.php cr&eacute;&eacute;e Thu Oct  9 17:51:06 2014
// ne changez pas la wikini_version manuellement!

$wakkaConfig = array (
  'wakka_version' => '0.1.1',
  'wikini_version' => '0.5.0',
  'yeswiki_version' => 'cercopitheque',
  'yeswiki_release' => '2022-03-07-1',
  'debug' => 'no',
  'mysql_host' => 'wiki-jardinalp-mariadb:3306',
  'mysql_database' => '${MARIADB_DB}',
  'mysql_user' => '${MARIADB_USER}',
  'mysql_password' => '${MARIADB_PASSWORD}',
  'table_prefix' => '${YW_DB_TABLE_PREFIX}',
  'base_url' => '${YW_BASE_URL}',
  'rewrite_mode' => '0',
  'meta_keywords' => '',
  'meta_description' => '',
  'action_path' => 'actions',
  'handler_path' => 'handlers',
  'header_action' => 'header',
  'footer_action' => 'footer',
  'navigation_links' => 'DerniersChangements :: DerniersCommentaires :: ParametresUtilisateur',
  'referrers_purge_time' => 24,
  'pages_purge_time' => 90,
  'default_write_acl' => '*',
  'default_read_acl' => '*',
  'default_comment_acl' => '@admins',
  'preview_before_save' => 0,
  'allow_raw_html' => '1',
  'timezone' => 'GMT',
  'root_page' => 'PagePrincipale',
  'wakka_name' => '${YW_NAME}',
  'formatter_path' => 'formatters',
  'default_language' => 'fr',
  'db_charset' => 'utf8mb4',
  //'favorite_theme' => 'bootstrap',
  //'favorite_style' => 'clapas.css',
  //'favorite_squelette' => '2cols-left-clapas.tpl.html',
  //'hide_action_template' => '1',
);
?>
