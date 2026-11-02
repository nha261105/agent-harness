# Tasks

## 1. Add the Troubleshooting section

- [x] 1.1 Read `README.md` in full, then insert a `## Troubleshooting` heading immediately after the end of the `## Check it works` section and before `## Notes`. Verify the `##` headings now read, in order: One-time machine setup, Reuse in another project, Check it works, Troubleshooting, Notes.
- [x] 1.2 Under that heading, add an English three-column Markdown table with the columns Symptom, Cause, Fix and the four rows described under "What Changes" in `proposal.md`. Verify the table has one header row and exactly four data rows, and that no cell is empty.

## 2. Check accuracy and scope

- [x] 2.1 Compare the `Fix` cell of row 1 with the install command already in the "One-time machine setup" section of `README.md`. Verify the two command strings are identical (`npm install -g @fission-ai/openspec@latest`).
- [x] 2.2 Check that row 4 names `openspec config profile` only as an option, with no claim that it was tested. Verify by re-reading the row against "Out of scope" in `proposal.md`.
- [x] 2.3 Re-read `README.md` and confirm every line that existed before task 1.1 is unchanged and only the new section was added. Verify no other file in the project was created or modified by this change (the only changed file is `README.md`).
