From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Mon, 11 Jan 2010 19:44:38 +0300
Subject: [Lustre-devel] SOM questions
In-Reply-To: <4B4B4801.7070509@sun.com>
References: <078f01ca8e31$22ff9f80$68fede80$@com>
	<05A3FFE9-1549-4B97-A9C3-4B82113E56AE@Sun.COM>
	<4B4B4801.7070509@sun.com>
Message-ID: <4B4B5576.2090405@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 1/11/10 6:47 PM, Alex Zhuravlev wrote:
> it looks quite simple and with very minimal changes to existing protocol
> logic. I also think that following this we don't need dedicated IO epoch
> notion and can use regular VBR version increasing on each open.

sorry, I forgot to add that all this essentially means no SOM-specific
in-core state on MDS at all and no need to maintain in-core state over
reboots.

thanks, Alex
