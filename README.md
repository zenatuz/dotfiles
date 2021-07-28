# My personal dotfiles

These files are my personal customization files that I use to personalize my Windows and/or Linux desktop experience.

There is a script `install.sh` that do the initial setup of all tools (**zsh, oh-my-zsh, powerlevel10k theme, oh-my-zsh plugins, brew and yadm**), and then applies the YADM at the end, which gets the customizations on your `~/`.

You can run the script directly with the following command:

```bash
curl -s -L https://git.io/JWjpB | bash
```

In the end, run the command to define ZSH as the default shell:
```bash
chsh -s $(which zsh)
```

## Prompt

This is how your prompt will look like after cloning the settings with YADM.

![Screenshot](screenshot.png)

> To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

## Getting the DOTFILEs, only

If you only want to get the files without installing anything new, just use YADM in your home directory.

```bash
cd ~
yadm clone git@github.com:zenatuz/dotfiles.git
```