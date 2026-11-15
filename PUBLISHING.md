# Upload this folder to GitHub

This folder is the repository root. Extract the ZIP into a new location; keep the initialized live deployment folder unchanged.

## Browser upload

1. Open your existing `qwe324fsf1324ffjgi/ec2-technical-test` repository, or create the intended repository.
2. Choose **Add file > Upload files**.
3. Open the extracted `ec2-technical-test` folder and upload its contents, so README.md and the .tf files are at the repository root. Do not upload the ZIP as the project.
4. Ensure `.gitignore` and `.terraform.lock.hcl` are included. Windows may hide dotfiles; enable File Explorer's hidden-item view if needed.
5. Review the file list and commit the upload.

If the repository already contains a project, review its existing files first. A browser upload does not remove obsolete tracked files, and ignore rules do not untrack files already committed. Do not overwrite unrelated repository work.

## Git workflow

For an existing repository, clone it into a separate directory, copy this folder's contents into the clone, inspect the diff and stage the intended files. Preserve repository history. For a new repository, initialize this folder and connect the remote deliberately. Avoid force pushes.

The package does not include a `.git` folder, a new commit or a remote write. The earlier destination name is included as context, not proof that the signed-in account can write to it.

## Validation and deployment

`ci/terraform.yml.example` is an inactive example. No workflow will run merely by uploading this folder. Terraform was not available in the packaging environment, so no new local `terraform validate` or provider initialization is claimed. Historical AWS/Terraform tests are documented with their evidence.

A GitHub upload does not deploy AWS resources. Use DEPLOYMENT.md for a deliberate new-account deployment or the original initialized operating folder for an existing-account update. Do not apply an old saved plan.
