class AddMediaAssociationsToLibraryEntry < ActiveRecord::Migration
  def up
    add_reference :library_entries, :anime, index: true
    add_reference :library_entries, :manga, index: true
    add_reference :library_entries, :drama, index: true

    execute <<-SQL.squish
      UPDATE library_entries
      SET anime_id = media_id
      WHERE media_type = 'Anime'
    SQL

    execute <<-SQL.squish
      UPDATE library_entries
      SET manga_id = media_id
      WHERE media_type = 'Manga'
    SQL
  end

  def down
    remove_reference :library_entries, :anime
    remove_reference :library_entries, :manga
    remove_reference :library_entries, :drama
  end
end
