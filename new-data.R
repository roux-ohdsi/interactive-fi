# organize data
# 
# 
library(here)

emis = list.files(here("docs", "data", "data"), pattern = "emis|imrd|ukbb", full.names = TRUE)

# move emis files to a folder called old
fs::file_move(
  path = emis,
  new_path = file.path(dirname(emis), "old/may2025", basename(emis))
)

emis = list.files(here("docs", "data", "data", "efi"), pattern = "emis|imrd|ukbb", full.names = TRUE)
fs::file_move(
  path = emis,
  new_path = file.path(dirname(emis), "old/may2025", basename(emis))
)

emis = list.files(here("docs", "data", "data", "vafi"), pattern = "emis|imrd|ukbb", full.names = TRUE)
fs::file_move(
  path = emis,
  new_path = file.path(dirname(emis), "old/may2025", basename(emis))
)

# # pasted in new files from Chen


# # 
# # 
# all_files = list.files(here("docs", "data", "data"), full.names = TRUE)
# files = all_files[
#   (grepl("emis|imrd|ukbb", all_files)) & grepl("efi", all_files)
# ]
# fs::file_copy(
#   path = files,
#   new_path = file.path(dirname(files), "efi5", basename(files))
# )
