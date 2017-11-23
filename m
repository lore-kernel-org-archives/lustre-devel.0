From: Rick Wagner <rick@globus.org>
Date: Thu, 23 Nov 2017 11:00:12 -0800
Subject: [lustre-devel] [lustre-discuss] strange time of reading for
 large file
In-Reply-To: <CY4PR06MB32554D7B2D35F990BD01F661BD210@CY4PR06MB3255.namprd06.prod.outlook.com>
References: <CY4PR06MB32554D7B2D35F990BD01F661BD210@CY4PR06MB3255.namprd06.prod.outlook.com>
Message-ID: <EA369C7B-467D-43EC-881A-9E2D2C8EA14F@globus.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Rosana,

Without knowing anything about your setup or test, my first question would be whether you accounted for caching between your read tests? That can occur at several layers within the environment, including the client, server, and underlying storage hardware. This is naturally a benefit when in production, but needs to understand during performance testing. And I?m assuming that your file system was not otherwise utilized during your tests. Another assumption would be that the file system was mostly empty so that file fragmentation and disk seeks weren?t a problem.

?Rick

> On Nov 23, 2017, at 10:52 AM, Rosana Guimaraes Ribeiro <rosana_guimaraes_@hotmail.com> wrote:
> 
> Hi,
> 
> I have some doubts about Lustre, I already sent my issues to forums but no one answer me.
> In our application, during the performance testing on lustre 2.4.2 we got times of reading and writing to test I/O operations with a file of almost 400GB. 
> Running this application a lot of times, consecutively, we see that in write operations, I/O time remain on same range, but in read operations there are a huge difference of time. As you can see below:
> Write time [sec]:
> 325.77
> 318.80
> 325.44
> 458.54
> 316.89
> 327.75
> 344.90
> 340.34
> 383.57
> 316.35
> Read time [sec]:
> 570.48
> 601.11
> 447.14
> 406.39
> 480.44
> 5824.40
> 299.40
> 293.54
> 1049.93
> 4190.47
> We ran on the single client with 1 process and tested on same infrastructure (hardware and network).
> Could you explain why is reading time so distorted? What kind of problem might be occurring?
> 
> Regards,
> Rosana
> 
> _______________________________________________
> lustre-discuss mailing list
> lustre-discuss at lists.lustre.org <mailto:lustre-discuss@lists.lustre.org>
> http://lists.lustre.org/listinfo.cgi/lustre-discuss-lustre.org <http://lists.lustre.org/listinfo.cgi/lustre-discuss-lustre.org>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171123/becbaa9b/attachment.html>
