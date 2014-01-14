Q: What is your goal?

A: Localize Slic3r [[project homepage]] (http://slic3r.org/) and an acceptance of pull-requet.

Slic3r-i18n
======

### What are Slic3r-i18n's key features?

* Localized message, GUI Text with GNU Gettext.

### I'm a developper. How to use gettext function?

* You have only to use ``Slic3r::_u``. This function is a wrapper of
  ``Locale::TextDomain::__``.

  ```
  # Someone translates into his language
  sub title { Slic3r::_u('Filament Settings') } 
  ```

  NOTE: ``Locale::TextDomain::__`` doesn't fit for Wx component. So use ``Slic3r::_u``.

### What are your policy?

```
1 "i18n-dev" branch is a trunk.
2 "i18n-stable" branch is a release.
3 "i18n-pullreq" branch is a pull-request.
```

### How to install?

#### Linux Users

All Linux distribution has gettext, I think. So, it's easy.

```
$ git clone https://github.com/KouOuchi/Slic3r-i18n.git
$ cd Slic3r
$ perl Build.PL
$ perl Build.PL --gui --i18n
$ LC_ALL=ru_RU.UTF-8 perl slic3r.pl --gui
```

#### Windows Users

To build gettext, get MSYS shell environment(http://www.mingw.org/wiki/Getting_Started).
``Base System`` and ``make`` are required.

NOTE: You may have to use the same compiler as you use in perl. 

And then, get latest gettext package ``gettext-0.18.3.1-1-mingw32-src.tar.lzma`` from (http://sourceforge.net/projects/mingw/files/MinGW/Base/gettext/gettext-0.18.3.1-1/).
Extract package and run shell script. 

```
$ tar xivf gettext-0.18.3.1-1-mingw32-src.tar.lzma
$ cd gettext-0.18.3.1-1-mingw32
$ tar xzvf gettext-0.18.3.1.tar.gz
$ cd gettext-0.18.3.1
$ patch -p1 < ../config.sub.patch
$ export PATH=/c/Apps/mingw64/bin:$PATH
$ ./configure --prefix=/c/Apps/mingw64 \
     --host=x86_64-w64-mingw32 --build=x86_64-w64-mingw32 
$ make
$ make install
```

NOTE: I tested on Windows7 64bit (Sitrus Perl & MinGW). MinGW is installed into /c/Apps/mingw64.

### Can I help?

Let's translate into your language.

### How can I add my mother tongue?

Add your language code to utils/i18n/gettext.pl.

```
$ gedit utils/i18n/gettext.pl
```

```
# Add your language 
my(@LOCALE_LIST)=("de", "fr", "it", "pt", "ru", "zh_CN", "nl", "es", "lv", "ja"); 
```

NOTE: If you don't know your language code, please see gettext website.

```
$ perl utils/i18n/gettext.pl
```

### How can I modify our language resource?

```
$ perl utils/i18n/gettext.pl
```

Edit .po(gettext resource) file. NOTE: To edit .po file you should get suitable
editor. e.g. poedit/emacs.
```
$ poedit var/po/slic3r-ru.po
```

Run utils/i18n/gettext.pl again. You get .mo(gettext catalogue) file.
```
$ perl utils/i18n/gettext.pl
```

Finally, set language environment value(LC_ALL) to your language code.

#### Linux Users
```
$ LC_ALL=ru_RU.UTF-8 perl slic3r.pl --gui
```

#### Windows Users
```
$ set LC_ALL=ru_RU.UTF-8
$ perl slic3r.pl --gui
```

### Screen Shot

## de
```
$ LC_ALL=de_DE.UTF-8 perl slic3r.pl --gui
```
![de](var/po/de.png)

## es
```
$ LC_ALL=es_ES.UTF-8 perl slic3r.pl --gui
```
![es](var/po/es.png)

## fr
```
$ LC_ALL=fr_FR.UTF-8 perl slic3r.pl --gui
```
![fr](var/po/fr.png)

## it
```
$ LC_ALL=it_IT.UTF-8 perl slic3r.pl --gui
```
![it](var/po/it.png)

## ja
```
$ LC_ALL=ja_JP.UTF-8 perl slic3r.pl --gui
```
![ja](var/po/ja.png)

## lv
```
$ LC_ALL=lv_LV.UTF-8 perl slic3r.pl --gui
```
![lv](var/po/lv.png)

## nl
```
$ LC_ALL=nl_NL.UTF-8 perl slic3r.pl --gui
```
![nl](var/po/nl.png)

## pt
```
$ LC_ALL=pt_PT.UTF-8 perl slic3r.pl --gui
```
![pt](var/po/pt.png)

## ru
```
$ LC_ALL=ru_RY.UTF-8 perl slic3r.pl --gui
```
![ru](var/po/ru.png)

## zh_CN
```
$ LC_ALL=zh_CN.UTF-8 perl slic3r.pl --gui
```
![zh_CN](var/po/zh_CN.png)
