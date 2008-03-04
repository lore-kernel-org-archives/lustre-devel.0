From: Nicholas Henke <nic@cray.com>
Date: Tue, 04 Mar 2008 08:46:09 -0600
Subject: [Lustre-devel] Thoughts on benchmarking
In-Reply-To: <47C87B4D.7070803@lbl.gov>
References: <47C336C8.4090108@lbl.gov>	<20080229211014.GQ2997@webber.adilger.int>
	<47C87B4D.7070803@lbl.gov>
Message-ID: <47CD60B1.5010701@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andrew C. Uselton wrote:
> Howdy Andreas,
>    Long time no electron :)
> 
>    The work on Franklin (NERSC's shiny new XT4) uses the Lustre 
> delivered and supported by Cray.  I believe it's 1.6.x, but I'd have to 
> ask around to get the details.  Is there a way to dig the Lustre version 
> out of a client?  

'cat /proc/fs/lustre/version'
or
strings /path/to/obdclass.ko | grep 'Build Version'

Nic
