From: Bradley W. Settlemyer <settlemyerbw@ornl.gov>
Date: Fri, 16 Oct 2009 11:37:16 -0400
Subject: [Lustre-devel] max_dirty_mb and fsync
In-Reply-To: <4AD76F52.4040706@ornl.gov>
References: <4AD76F52.4040706@ornl.gov>
Message-ID: <4AD8932C.9070602@ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Obviously, when I write 32MB in the second paragraph I mean 4MB.  Sorry 
for the error.

Cheers
Brad


On 10/15/2009 02:52 PM, Bradley W. Settlemyer wrote:
> Hello
>
>     What is the difference between setting the max_dirty_mb setting in
> /proc to 4 and making sure that all of my applications fsync every 4MBs
> of data that are transmitted?
>
>     I would guess that one difference is the 32MB is a filesystem-wide
> setting rather than a per file setting -- so the sync occurs regardless
> of the number of files receiving data.  But are there any other
> differences with regards to the interaction with the file system.
>
>     More to the point perhaps, does an fsync have additional side effects
> beyond those that occur for the max_dirty_mb threshhold being exceeded?
>
> Cheers,
> Brad
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
