
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<spring:url value="/resources/images/etechlogo.jpg" var="etechlogo" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Etech Consulting llc- Home Page</title>
<link href="${etechlogo}" rel="icon">
</head>
</head>
<body>
<h1 align="center">Welcome to Etech Consulting Devops Master Class.</h1>
<h1 align="center">We are a software solutions company and DevOps online training platform in New York and Ohio and Job Support also...Teaching 90% practical skills</h1>
<hr>
<div style="text-align: center;">
	<span>
		<img src="${etechlogo}" alt="" width="100"/>

	</span>
	<span style="font-weight: bold;">
		Etech Consulting LLC, 
		New york,United States Of America
		+13478735512/+16677868741/+17189244942.
		
	</span>
</div>
<hr>
	<p> Service : <a href="${pageContext.request.contextPath}/services/getEmployeeDetails">Get Employee Details </p>
<hr>
<p align=center>Etech Consulting llc - Consultant, Training, Software Development company.</p>
<p align=center><small>Copyrights 2022 by <a href="http://www.etecconsultingllc.com/">Etech Consulting LLC</a> </small></p>

</body>
</html>
