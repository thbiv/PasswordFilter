Deploy PasswordFilter {
    By PSGalleryModule {
        FromSource "$PSScriptRoot\_output\PasswordFilter"
        To SFGallery
    }
}