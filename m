From: =?ISO-8859-1?Q?Aur=E9lien_Degr=E9mont?= <aurelien.degremont@cea.fr>
Date: Thu, 09 Dec 2010 21:15:20 +0100
Subject: [Lustre-devel] Git commit message format
In-Reply-To: <20101209165030.GA2370@granier.hd.free.fr>
References: <9E373505737CCD46890A96FA1877E8DA01D9824E@XY01EX22.xy01.xyratex.com>
	<20101209165030.GA2370@granier.hd.free.fr>
Message-ID: <4D0138D8.3000505@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Le 09/12/2010 17:50, Johann Lombardi a ?crit :
> This stands for "author". This is used when the author of the patch is 
> different from the person who submits it. While this was needed for 
> CVS, we can now easily change the "Author" field with git and land a 
> patch on behalf of someone else.
I think it could be good that git commit reflets the real patch author. 
(This could be useful for Ohloh by the way :-))
But may be you could find it useful for internal process to know who 
really comitted it, and in this case, it could be better to add a tag 
'c=' for committer, and git author is the real patch author.


Aur?lien
