let allResults = []
let isExpanded = false

let searchButton;
let clearButton;
let keywordsInput;
let priceFromInput;
let priceToInput;
let sortBySelect;
let resultsArea;
let conditionCheckboxes;
let sellerCheckboxes;
let shippingCheckboxes;


function displayResults(results, total) {
  resultsArea.innerHTML = '';

  if (total === 0) {
    console.log("no result")
    const noResultsElement = document.createElement('h2');
    noResultsElement.id = 'no-results';
    noResultsElement.textContent = 'No Results found';

    noResultsElement.style.marginTop = '20px'; 
    noResultsElement.style.marginLeft = '850px'; 

    resultsArea.appendChild(noResultsElement);
    return;  
  }

  
  const totalResultsElement = document.createElement('h2');
  totalResultsElement.id = 'total-results';
  totalResultsElement.textContent = `${total} Results found for `;
  
  const keywordsElement = document.createElement('em');
  keywordsElement.id = 'keywords-em';
  keywordsElement.textContent = keywordsInput.value.trim();
  totalResultsElement.appendChild(keywordsElement);

  const hrElement = document.createElement('hr');
  totalResultsElement.appendChild(hrElement);
  

  resultsArea.appendChild(totalResultsElement);
    console.log(results)


    results.forEach(item => {
      const resultDiv = document.createElement('div');
      resultDiv.className = 'search-result';
  
      const imgDiv = document.createElement('div');
      imgDiv.className = 'image-container';
  

      const imgElement = document.createElement('img');

      if (item.image && item.image !== '') {
        imgElement.src = item.image;
      } else {
        imgElement.src = '../static/images/ebay_default.jpg';  
      }

      imgDiv.appendChild(imgElement);
      imgDiv.className = 'image-container expandable';
      const infoDiv = document.createElement('div');
      infoDiv.className = 'info-container';
          
 
      const titleElement = document.createElement('p');
      titleElement.className = 'product-title'; 
      titleElement.textContent = item.title;
      infoDiv.appendChild(titleElement);
  

      const categoryElement = document.createElement('p');  
      categoryElement.className = 'product-info';  

      const categoryLabel = document.createElement('span');  
      categoryLabel.textContent = 'Category: ';
      categoryElement.appendChild(categoryLabel);  

      const categoryValue = document.createElement('span');  
      categoryValue.className = 'italic-text';  
      categoryValue.textContent = item.category;
      categoryElement.appendChild(categoryValue);  


      const linkElement = document.createElement('a');
      linkElement.href = item.itemUrl;  
      linkElement.target = '_blank';  


      const linkIcon = document.createElement('img');
      linkIcon.src = '../static/images/redirect.png';  
      linkIcon.alt = 'View on eBay';
      linkIcon.className = 'link-icon';  
      linkIcon.style.display = 'inline';

    
      linkElement.appendChild(linkIcon);

      categoryElement.appendChild(linkElement);

      infoDiv.appendChild(categoryElement);  

  
  
      const conditionElement = document.createElement('p');
      conditionElement.className = 'product-info';  

      const conditionText = document.createElement('span');
      conditionText.textContent = 'Condition: ' + item.condition;
      conditionElement.appendChild(conditionText);

  
      if (item.topRated==="true") {
          const topRatedIcon = document.createElement('img');
          topRatedIcon.className = 'top-rated-icon';  
          topRatedIcon.src = '../static/images/topRatedImage.png';  
          topRatedIcon.style.display = 'inline';
          conditionElement.appendChild(topRatedIcon);
      }

      infoDiv.appendChild(conditionElement);


 
      const priceElement = document.createElement('p');
      priceElement.className = 'price-info';  

      if (item.shippingFee && item.shippingFee !== "0.0") {
          priceElement.textContent = `Price: $${item.price} ( + $${item.shippingFee} for shipping)`;
      } else {
          priceElement.textContent = `Price: $${item.price}`;
      }

      infoDiv.appendChild(priceElement);

      resultDiv.appendChild(imgDiv);
      resultDiv.appendChild(infoDiv);


      resultDiv.addEventListener('click', function() {
        console.log(item.itemID)
        fetchDetailedInfo(item.itemID); 
      });


      resultsArea.appendChild(resultDiv);
  });

  if (!isExpanded) {
    const showMoreButton = createButton("show-more", "Show More", () => {
      isExpanded = true;
      displayResults(allResults.slice(0,10), total);
    });
    resultsArea.appendChild(showMoreButton);
  } else {
    const showLessButton = createButton("show-less", "Show Less", () => {
      isExpanded = false;
      displayResults(allResults.slice(0, 3), total);
    });
    resultsArea.appendChild(showLessButton);
  }
}
function createButton(id, text, clickHandler) {
  const button = document.createElement("button");
  button.id = id;
  button.textContent = text;
  button.addEventListener("click", clickHandler);

  button.style.width = "100px";
  button.style.height = "30px";
  button.style.marginTop = "5px";
  button.style.marginLeft = "900px";
  
  return button;

}

document.addEventListener("DOMContentLoaded", function() {

  searchButton = document.getElementById("search");
  clearButton = document.getElementById("clear");
  keywordsInput = document.getElementById("keywords");
  priceFromInput = document.getElementById("price-from");
  priceToInput = document.getElementById("price-to");
  sortBySelect = document.getElementById("sort-by");
  resultsArea = document.getElementById('results-area'); 
  conditionCheckboxes = document.querySelectorAll("input[name='condition']");
  sellerCheckboxes = document.querySelectorAll("input[name='seller']");
  shippingCheckboxes = document.querySelectorAll("input[name='shipping']");



 
  searchButton.addEventListener("click", function() {
    isExpanded = false


    if (keywordsInput.value.trim() === "") {
      alert("Please fill out this field.");
      return;
    }

    const fromPrice = parseFloat(priceFromInput.value);
    const toPrice = parseFloat(priceToInput.value);


    if (fromPrice < 0 || toPrice < 0) {
      alert("Negative numbers are not allowed.");
      return;
    }

    if (fromPrice > toPrice) {
      alert("The 'from' value cannot be greater than the 'to' value.");
      return;
    }


    let queryString = `?query=${keywordsInput.value.trim()}`;
    if (priceFromInput.value !== '') {
      queryString += `&minPrice=${priceFromInput.value}`;
    }
    if (priceToInput.value !== '') {
      queryString += `&maxPrice=${priceToInput.value}`;
    }

    queryString += `&sortOrder=${sortBySelect.value}`;

    conditionCheckboxes.forEach(checkbox => {
      if (checkbox.checked) {
        queryString += `&condition=${checkbox.value}`;
      }
    });

    sellerCheckboxes.forEach(checkbox => {
      if (checkbox.checked) {
        queryString += `&seller=${checkbox.value}`;
      }
    });

    shippingCheckboxes.forEach(checkbox => {
      if (checkbox.checked) {
        queryString += `&shipping=${checkbox.value}`;
      }
    });




    fetch(`/search${queryString}`)
    .then(response => response.json())
    .then(data => {

      if (data && data.results && data.results.length > 0) {
        allResults = data.results;
        displayResults(allResults.slice(0, 3), data.total);   
      } else {
        displayResults(allResults, data.total);
      }
    })
    .catch(error => {
      
    });
});




clearButton.addEventListener("click", function() {
    keywordsInput.value = "";
    priceFromInput.value = "";
    priceToInput.value = "";
    sortBySelect.value = "best-match";

    const allCheckboxes = document.querySelectorAll("input[type='checkbox']");
    allCheckboxes.forEach(function(checkbox) {
      checkbox.checked = false;
    });
  });
});



function fetchDetailedInfo(item_id) {
  fetch(`/getSingleItem/${item_id}`)
    .then(response => response.json())
    .then(data => {
      const resultsArea = document.getElementById('results-area');
      resultsArea.innerHTML = '';

      const h1 = document.createElement('h1');
      h1.textContent = 'Item Details';
      h1.className = 'ItemDetals-title'
      resultsArea.appendChild(h1);

      const detailedInfoTable = document.createElement('table');
      detailedInfoTable.className = 'detailed-info-table';


      const tbody = document.createElement('tbody');

      const fixedAttributes = ['Photo', 'eBayLinkTitle', 'Title', 'Price', 'Location', 'Seller', 'ReturnPolicy'];
      for (const attribute of fixedAttributes) {
        const row = document.createElement('tr');
        row.className = 'data-row';
        const cell1 = document.createElement('td');
        cell1.className = 'data-cell attribute-label';
        cell1.textContent = attribute === 'eBayLinkTitle' ? 'Ebay_Product_Link' : attribute;
        row.appendChild(cell1);

        const cell2 = document.createElement('td');
        cell2.className = 'data-cell';
        if (attribute === 'Photo') {
          const img = document.createElement('img');
          img.className = 'productImage'
          img.src = data[attribute][0];
          cell2.appendChild(img);
        } else if (attribute === 'eBayLinkTitle') {
          const a = document.createElement('a');
          a.href = data[attribute];
          a.textContent = "Ebay_Product_Link";
          a.target = "_blank";
          cell2.appendChild(a);
        } else if (attribute === 'ReturnPolicy') {
          let returnPolicy = 'Returns Not Accepted'; 
          if (data[attribute].ReturnsAccepted === 'Returns Accepted') {
            returnPolicy = `Return Accepted within ${data[attribute].ReturnsWithin}`;
          }
          cell2.textContent = returnPolicy;
        }else if (attribute === 'Location' && data.PostalCode) {
            cell2.textContent = `${data[attribute]}, ${data.PostalCode}`;
        } else {
          cell2.textContent = data[attribute];
        }
        row.appendChild(cell2);
        tbody.appendChild(row);
      }

      // Handle ItemSpecifics separately
      for (const specific of data.ItemSpecifics) {
        const row = document.createElement('tr');
        const cell1 = document.createElement('td');
        cell1.className = 'attribute-label';
        cell1.textContent = specific.Name;
        row.appendChild(cell1);

        const cell2 = document.createElement('td');
        
        cell2.textContent = specific.Value.join(', '); // Handle array values
        row.appendChild(cell2);

        tbody.appendChild(row);
      }

      detailedInfoTable.appendChild(tbody);

      const backButton = document.createElement('button');
      backButton.textContent = 'Back to search results';
      backButton.className = 'back-button';
      backButton.addEventListener('click', goBackToSearchResults);  
      resultsArea.appendChild(backButton);

      resultsArea.appendChild(detailedInfoTable);
    })
    .catch(error => {
      console.log("Error fetching detailed information: ", error);
    });

    function goBackToSearchResults() {

      const resultsArea = document.getElementById('results-area');
      resultsArea.innerHTML = '';
      

      if (allResults.length > 0) {
        if (isExpanded) {
          displayResults(allResults.slice(0, 10), allResults.length); 
        } else {
          displayResults(allResults.slice(0, 3), allResults.length); 
        }
      } else {

      }
    }  
}


